//
//  AccessibilityAnnouncer.swift
//  entourage
//
//  Annonce vocale (VoiceOver) des messages d'erreur : un seul point d'entrée pour les formulaires,
//  les alertes, les toasts et les échecs d'API, au lieu d'une annonce écran par écran.
//  Modèle : SuggestionSnackbar, qui poste déjà `.announcement`.
//

import UIKit

enum AccessibilityAnnouncer {

    /// Couture de test : par défaut, l'état réel de VoiceOver et la vraie notification.
    static var isVoiceOverActive: () -> Bool = { UIAccessibility.isVoiceOverRunning }
    static var post: (UIAccessibility.Notification, Any?) -> Void = { UIAccessibility.post(notification: $0, argument: $1) }

    /// Annonce `message` à voix haute si VoiceOver tourne. Un message vide ou nil n'annonce rien.
    /// Peut être appelée depuis n'importe quel thread.
    static func announce(_ message: String?) {
        guard let message = message?.trimmingCharacters(in: .whitespacesAndNewlines), !message.isEmpty else { return }
        guard isVoiceOverActive() else { return }
        if Thread.isMainThread {
            post(.announcement, message)
        } else {
            DispatchQueue.main.async { post(.announcement, message) }
        }
    }
}
