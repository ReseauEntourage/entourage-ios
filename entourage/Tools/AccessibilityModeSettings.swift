//
//  AccessibilityModeSettings.swift
//  entourage
//
//  Réglage « Contraste amélioré » : un tri-état par compte (aucun choix / activé / désactivé), mémorisé sur
//  l'appareil, et son activation automatique quand VoiceOver tourne. Même règles qu'Android
//  (`AccessibilityModeSettings.kt`) ; le suivi entre appareils et plateformes est un change séparé
//  (voir le change OpenSpec add-accessibility-mode, décision D2).
//

import UIKit

struct AccessibilityModeSettings {

    enum Choice: Equatable {
        /// L'utilisateur n'a jamais activé ni désactivé le mode.
        case unset
        case enabled
        case disabled
    }

    /// Le mode est livré en un seul bloc (change add-accessibility-mode, groupe 9) : tant que le moteur de palette
    /// n'est pas en place, il n'y a ni ligne « Accessibilité » dans les paramètres, ni activation automatique
    /// (qui engagerait le choix des comptes existants avant la décision du PM). À passer à `true` avec le groupe 9.
    static var isContrastModeAvailable = false

    private let userId: Int
    private let store: UserDefaults
    private let screenReaderActive: () -> Bool

    init(userId: Int, store: UserDefaults = .standard, screenReaderActive: @escaping () -> Bool = { UIAccessibility.isVoiceOverRunning }) {
        self.userId = userId
        self.store = store
        self.screenReaderActive = screenReaderActive
    }

    /// Réglage du compte connecté, ou nil si personne n'est connecté (écrans d'avant connexion).
    static var forCurrentUser: AccessibilityModeSettings? {
        guard let user = UserDefaults.currentUser else { return nil }
        return AccessibilityModeSettings(userId: user.sid)
    }

    /// Même clé qu'Android.
    private var key: String { "high_contrast_user_\(userId)" }

    var choice: Choice {
        guard let value = store.object(forKey: key) as? Bool else { return .unset }
        return value ? .enabled : .disabled
    }

    /// Le mode est actif seulement après un choix explicite ou une activation automatique.
    var isHighContrastEnabled: Bool { choice == .enabled }

    func setHighContrast(_ enabled: Bool) {
        store.set(enabled, forKey: key)
    }

    /// À l'ouverture de la session : tant qu'aucun choix n'est enregistré et que VoiceOver tourne, active le mode
    /// et l'enregistre. Ne réactive jamais un mode désactivé, ne désactive jamais un mode activé.
    /// - Returns: l'état du mode après l'appel.
    @discardableResult
    func refresh(available: Bool = AccessibilityModeSettings.isContrastModeAvailable) -> Bool {
        guard available else { return false }
        if choice == .unset && screenReaderActive() {
            setHighContrast(true)
        }
        return isHighContrastEnabled
    }
}
