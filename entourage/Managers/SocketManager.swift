//
//  SocketManager.swift
//  entourage
//
//  Client ActionCable natif (URLSessionWebSocketTask) pour le canal temps réel
//  unique `ConversationChannel` — messages, réactions et mouvements de membres
//  des conversations, discussions d'outing, groupes de voisins et smalltalks.
//

import Foundation

/// Événement applicatif reçu sur une trame de données ActionCable.
struct SocketChannelEvent {
    let type: String            // chat_message_created / _updated / user_reaction_added / _removed / member_joined / member_left
    let userId: Int
    let instanceType: String    // ChatMessage / UserReaction / JoinRequest
    let instanceId: Int
    let rawData: [String: Any]
}

extension SocketChannelEvent {
    /// Redécode `rawData` vers le type attendu selon `type` (ex: PostMessage, ChatReactionEvent).
    func decodeData<T: Decodable>(as type: T.Type) -> T? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rawData) else { return nil }
        return try? JSONDecoder().decode(T.self, from: jsonData)
    }

    /// `chat_message_created`/`chat_message_updated` : le message peut être exposé à plat dans
    /// `data`, ou imbriqué sous `data.chat_message` selon les cas — on essaie les deux formes
    /// plutôt que d'échouer silencieusement (un décodage à plat raté renvoie un objet vide qui
    /// ne matche jamais rien côté client, donnant l'impression que l'événement est ignoré).
    func decodeMessage() -> PostMessage? {
        if let message = decodeData(as: PostMessage.self) {
            return message
        }
        guard let nested = rawData["chat_message"] as? [String: Any],
              let jsonData = try? JSONSerialization.data(withJSONObject: nested) else { return nil }
        return try? JSONDecoder().decode(PostMessage.self, from: jsonData)
    }
}

final class SocketManager: NSObject {

    static let shared = SocketManager()

    /// Handle opaque rendu à l'appelant de `subscribe`, à conserver pour `unsubscribe`.
    final class Token {
        fileprivate let identifier: String
        fileprivate let listenerId: UUID
        fileprivate init(identifier: String, listenerId: UUID) {
            self.identifier = identifier
            self.listenerId = listenerId
        }
    }

    private struct Listener {
        let id: UUID
        let onEvent: (SocketChannelEvent) -> Void
        let onReconnected: (() -> Void)?
    }

    private struct Subscription {
        var listeners: [Listener] = []
        var isConfirmed = false
    }

    private let queue = DispatchQueue(label: "social.entourage.socketmanager")
    private var subscriptions: [String: Subscription] = [:]
    private var urlSession: URLSession?
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    private var isConnecting = false
    private var reconnectAttempt = 0
    private var reconnectWorkItem: DispatchWorkItem?

    private override init() {
        super.init()
    }

    // MARK: - API publique

    @discardableResult
    func subscribe(instanceType: String,
                    instanceId: Int,
                    onEvent: @escaping (SocketChannelEvent) -> Void,
                    onReconnected: (() -> Void)? = nil) -> Token {
        let identifier = Self.makeIdentifier(instanceType: instanceType, instanceId: instanceId)
        let listener = Listener(id: UUID(), onEvent: onEvent, onReconnected: onReconnected)
        let token = Token(identifier: identifier, listenerId: listener.id)

        queue.async { [weak self] in
            guard let self = self else { return }
            var subscription = self.subscriptions[identifier] ?? Subscription()
            let isFirstListener = subscription.listeners.isEmpty
            subscription.listeners.append(listener)
            self.subscriptions[identifier] = subscription

            if isFirstListener {
                self.connectIfNeeded()
                if self.isConnected {
                    self.sendSubscribe(identifier: identifier)
                }
            }
        }

        return token
    }

    func unsubscribe(_ token: Token?) {
        guard let token = token else { return }
        queue.async { [weak self] in
            guard let self = self, var subscription = self.subscriptions[token.identifier] else { return }
            subscription.listeners.removeAll { $0.id == token.listenerId }

            if subscription.listeners.isEmpty {
                self.subscriptions.removeValue(forKey: token.identifier)
                if self.isConnected {
                    self.sendUnsubscribe(identifier: token.identifier)
                }
                if self.subscriptions.isEmpty {
                    self.disconnect()
                }
            } else {
                self.subscriptions[token.identifier] = subscription
            }
        }
    }

    // MARK: - Identifier (chaîne stable, ordre de clés fixe — subscribe/unsubscribe doivent
    // envoyer exactement la même chaîne, comparée telle quelle côté serveur)

    private static func makeIdentifier(instanceType: String, instanceId: Int) -> String {
        return "{\"channel\":\"ConversationChannel\",\"instance_type\":\"\(instanceType)\",\"instance_id\":\(instanceId)}"
    }

    // MARK: - Connexion (tout ce qui suit s'exécute uniquement sur `queue`)

    private func connectIfNeeded() {
        guard !isConnected, !isConnecting else { return }
        guard let token = UserDefaults.token, !token.isEmpty else { return }

        // ActionCable vit sur le serveur API (ex: api-preprod.entourage.social), pas sur le
        // domaine web public (`baseURL`, ex: preprod.entourage.social) utilisé par ailleurs
        // pour les liens — confondre les deux fait échouer le handshake (mauvais host).
        guard let apiHost = URL(string: EnvironmentConfigurationManager.sharedInstance.APIHostURL as String)?.host else { return }
        let appOrigin = EnvironmentConfigurationManager.sharedInstance.baseURL
        let encodedToken = token.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? token
        guard let url = URL(string: "wss://\(apiHost)/cable?token=\(encodedToken)") else { return }

        // Un client natif n'envoie normalement aucun header Origin — si le back valide quand
        // même l'origine (protection CSRF ActionCable non désactivée pour les clients mobiles),
        // son absence fait répondre une page d'erreur HTTP au lieu du 101 Switching Protocols
        // attendu, ce que URLSession remonte sous la forme générique -1011 "bad server response"
        // (constaté aussi bien avec qu'sans ce header tant que le host était encore erroné).
        var request = URLRequest(url: url)
        request.setValue(appOrigin, forHTTPHeaderField: "Origin")

        isConnecting = true
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        urlSession = session
        let task = session.webSocketTask(with: request)
        webSocketTask = task
        task.resume()
        listen()
    }

    private func disconnect() {
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
        reconnectAttempt = 0
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        isConnected = false
        isConnecting = false
    }

    private func scheduleReconnect() {
        guard !subscriptions.isEmpty else { return }
        reconnectWorkItem?.cancel()
        let delay = min(30.0, pow(2.0, Double(reconnectAttempt)))
        reconnectAttempt += 1
        let workItem = DispatchWorkItem { [weak self] in
            self?.connectIfNeeded()
        }
        reconnectWorkItem = workItem
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    // MARK: - Envoi

    private func send(command: String, identifier: String) {
        let payload: [String: Any] = ["command": command, "identifier": identifier]
        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let text = String(data: data, encoding: .utf8) else { return }
        webSocketTask?.send(.string(text)) { _ in }
    }

    private func sendSubscribe(identifier: String) {
        send(command: "subscribe", identifier: identifier)
    }

    private func sendUnsubscribe(identifier: String) {
        send(command: "unsubscribe", identifier: identifier)
    }

    private func resubscribeAll() {
        for identifier in subscriptions.keys {
            sendSubscribe(identifier: identifier)
        }
    }

    // MARK: - Réception

    private func listen() {
        queue.async { [weak self] in
            guard let self = self, let task = self.webSocketTask else { return }
            task.receive { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let message):
                    if case .string(let text) = message {
                        self.handle(text: text)
                    }
                    self.listen()
                case .failure:
                    self.queue.async {
                        self.isConnected = false
                        self.isConnecting = false
                        self.scheduleReconnect()
                    }
                }
            }
        }
    }

    private func handle(text: String) {
        guard let data = text.data(using: .utf8),
              let frame = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

        if let controlType = frame["type"] as? String {
            queue.async { [weak self] in
                self?.handleControlFrame(type: controlType, frame: frame)
            }
            return
        }

        guard let identifier = frame["identifier"] as? String,
              let message = frame["message"] as? [String: Any],
              let eventType = message["type"] as? String,
              let userId = message["user_id"] as? Int,
              let instanceType = message["instance_type"] as? String,
              let instanceId = message["instance_id"] as? Int,
              let eventData = message["data"] as? [String: Any] else { return }

        let event = SocketChannelEvent(type: eventType, userId: userId, instanceType: instanceType, instanceId: instanceId, rawData: eventData)

        queue.async { [weak self] in
            guard let self = self, let subscription = self.subscriptions[identifier] else { return }
            let listeners = subscription.listeners
            DispatchQueue.main.async {
                listeners.forEach { $0.onEvent(event) }
            }
        }
    }

    /// Exécuté sur `queue`.
    private func handleControlFrame(type: String, frame: [String: Any]) {
        switch type {
        case "welcome":
            isConnected = true
            isConnecting = false
            reconnectAttempt = 0
            resubscribeAll()

        case "ping":
            break // simple battement de cœur, à ignorer

        case "confirm_subscription":
            guard let identifier = frame["identifier"] as? String,
                  var subscription = subscriptions[identifier] else { return }
            let wasAlreadyConfirmed = subscription.isConfirmed
            subscription.isConfirmed = true
            subscriptions[identifier] = subscription

            if wasAlreadyConfirmed {
                // Reconfirmation après une coupure : les écrans doivent recharger via REST
                // pour combler le trou (ActionCable ne rejoue aucun historique).
                let listeners = subscription.listeners
                DispatchQueue.main.async {
                    listeners.forEach { $0.onReconnected?() }
                }
            }

        case "reject_subscription":
            break // pas membre / id introuvable : accès refusé, on ne retente pas

        case "disconnect":
            isConnected = false
            scheduleReconnect()

        default:
            break
        }
    }
}

extension SocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                     didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        queue.async { [weak self] in
            self?.isConnected = false
            self?.isConnecting = false
            self?.scheduleReconnect()
        }
    }

    // Un échec au moment même du handshake (mauvais host, réponse HTTP invalide, etc.) est
    // signalé ici — PAS par `didCloseWith`, qui ne concerne que la fermeture d'une connexion
    // WebSocket déjà établie. Sans ce handler, `isConnecting` reste bloqué à `true` et plus
    // aucune tentative de connexion n'est retentée pour le reste de la session.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard error != nil else { return }
        queue.async { [weak self] in
            self?.isConnected = false
            self?.isConnecting = false
            self?.scheduleReconnect()
        }
    }

    // Diagnostic temporaire : en cas d'échec du handshake, la seule erreur -1011 générique ne dit
    // pas *pourquoi* (mauvaise réponse HTTP ? négociation HTTP/2 au lieu de HTTP/1.1, qui casse
    // l'upgrade WebSocket derrière certains proxys ?). Ces métriques exposent le vrai statut HTTP
    // reçu et le protocole réseau négocié (`http/1.1` vs `h2`).
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard let last = metrics.transactionMetrics.last else { return }
        let status = (last.response as? HTTPURLResponse)?.statusCode
        print("[SocketManager] handshake diagnostic — protocol: \(last.networkProtocolName ?? "?"), HTTP status: \(status.map(String.init) ?? "?")")
    }
}
