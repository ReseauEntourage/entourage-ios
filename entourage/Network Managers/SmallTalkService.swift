import Foundation

struct SmallTalkService: ParsingDataCodable {
    
    // MARK: - Lister les requêtes SmallTalk de l'utilisateur
    static func listUserSmallTalkRequests(completion: @escaping ([UserSmallTalkRequest]?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "user_smalltalks?token=\(token)"

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                let decoded = try JSONDecoder().decode(UserSmallTalkRoot.self, from: data)
                completion(decoded.user_smalltalks, nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - Créer une requête SmallTalk
    static func createUserSmallTalkRequest(completion: @escaping (UserSmallTalkRequest?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = String(format: kAPIUserSmallTalkRequests + "?token=%@", token)

        let body = ["user_smalltalk": [:]]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let request: UserSmallTalkRequest? = self.parseData(data: data, key: "user_smalltalk")
            completion(request, nil)
        }
    }

    // MARK: - Mettre à jour une requête SmallTalk
    static func updateUserSmallTalkRequest(id: String, updates: [String: Any], completion: @escaping (UserSmallTalkRequest?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "user_smalltalks/\(id)?token=\(token)"
        let body = try! JSONSerialization.data(withJSONObject: updates, options: [])

        NetworkManager.sharedInstance.requestPatch(endPoint: endpoint, headers: nil, body: body) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let request: UserSmallTalkRequest? = self.parseData(data: data, key: "user_smalltalk")
            completion(request, nil)
        }
    }

    // MARK: - Demander un match
    static func matchRequest(id: String, completion: @escaping (SmallTalkMatchResponse?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "user_smalltalks/\(id)/match?token=\(token)"

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let response = try? JSONDecoder().decode(SmallTalkMatchResponse.self, from: data)
            completion(response, nil)
        }
    }

    // MARK: - Supprimer une requête SmallTalk
    static func deleteRequest(completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "user_smalltalks?token=\(token)"

        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { _, response, error in
            completion(error == nil && (response as? HTTPURLResponse)?.statusCode ?? 500 < 300)
        }
    }

    // MARK: - Lister tous les SmallTalks (ouverts)
    static func listSmallTalks(completion: @escaping ([SmallTalk]?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "smalltalks?token=\(token)"

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let talks: [SmallTalk]? = self.parseDatas(data: data, key: "smalltalks")
            completion(talks, nil)
        }
    }

    // MARK: - Récupérer un SmallTalk précis
    static func getSmallTalk(id: String, completion: @escaping (SmallTalk?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "smalltalks/\(id)?token=\(token)"

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let talk: SmallTalk? = self.parseData(data: data, key: "smalltalk")
            completion(talk, nil)
        }
    }

    // MARK: - Lister les participants d’un SmallTalk
    static func listParticipants(id: String, completion: @escaping ([UserLightNeighborhood]?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "smalltalks/\(id)/users?token=\(token)"

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let users: [UserLightNeighborhood]? = self.parseDatas(data: data, key: "users")
            completion(users, nil)
        }
    }

    // MARK: - Lister les messages du SmallTalk
    static func listMessages(id: String, completion: @escaping ([PostMessage]?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "smalltalks/\(id)/chat_messages?token=\(token)"

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let messages: [PostMessage]? = self.parseDatas(data: data, key: "chat_messages")
            completion(messages, nil)
        }
    }

    // MARK: - Créer un message dans un SmallTalk
    static func createMessage(id: String, content: String, completion: @escaping (PostMessage?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "smalltalks/\(id)/chat_messages?token=\(token)"
        let body = ["chat_message": ["content": content]]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            let message: PostMessage? = self.parseData(data: data, key: "chat_message")
            completion(message, nil)
        }
    }

    // MARK: - Supprimer un message
    static func deleteMessage(smallTalkId: String, messageId: String, completion: @escaping (Bool) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "smalltalks/\(smallTalkId)/chat_messages/\(messageId)?token=\(token)"

        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { _, response, error in
            completion(error == nil && (response as? HTTPURLResponse)?.statusCode ?? 500 < 300)
        }
    }
}

// MARK: - Dictionnaire utilisé lors des appels POST/PATCH
extension UserSmallTalkRequest {
    func dictionaryForWS() -> [String: Any] {
        var dict = [String: Any]()
        dict["match_format"] = match_format
        dict["match_locality"] = match_locality ?? false
        dict["match_gender"] = match_gender ?? false
        dict["match_interest"] = match_interest ?? false
        return dict
    }
}

// MARK: - Struct pour décoder la réponse JSON de listUserSmallTalkRequests
struct UserSmallTalkRoot: Codable {
    let user_smalltalks: [UserSmallTalkRequest]
}

// MARK: - Struct de réponse pour le /match
struct SmallTalkMatchResponse: Codable {
    let match: Bool
    let smalltalk_id: Int?
}
