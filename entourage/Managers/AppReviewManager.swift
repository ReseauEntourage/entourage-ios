//
//  AppReviewManager.swift
//  entourage
//
//  Demande d'avis App Store native après des actions positives de l'utilisateur (EN-7425).
//

import UIKit
import StoreKit

/// Compte les actions positives (participer à un événement, publier, réagir, clôturer une entraide…)
/// et demande l'avis App Store au bon moment, sans jamais harceler l'utilisateur :
/// - au moins `actionsBeforeRequest` actions positives depuis la dernière demande ;
/// - au plus une demande par version de l'app ;
/// - au moins `minDaysBetweenRequests` jours entre deux demandes (Apple plafonne de toute façon à 3 par an).
final class AppReviewManager {
    static let shared = AppReviewManager()

    private let actionsBeforeRequest = 3
    private let minDaysBetweenRequests = 90
    private let delayBeforeRequest: TimeInterval = 1.5

    private let actionCountKey = "appReviewPositiveActionCount"
    private let lastVersionKey = "appReviewLastRequestedVersion"
    private let lastDateKey = "appReviewLastRequestDate"

    private let defaults = UserDefaults.standard

    private init() {}

    /// À appeler quand une action positive vient d'aboutir côté serveur.
    func recordPositiveAction() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UITestMode") { return }
        #endif

        let count = defaults.integer(forKey: actionCountKey) + 1
        defaults.set(count, forKey: actionCountKey)

        guard count >= actionsBeforeRequest, canRequestReview() else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delayBeforeRequest) { [weak self] in
            self?.requestReview()
        }
    }

    private var currentVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    private func canRequestReview() -> Bool {
        if defaults.string(forKey: lastVersionKey) == currentVersion { return false }
        if let lastDate = defaults.object(forKey: lastDateKey) as? Date {
            let days = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if days < minDaysBetweenRequests { return false }
        }
        return true
    }

    private func requestReview() {
        guard UIApplication.shared.applicationState == .active,
              let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }

        SKStoreReviewController.requestReview(in: scene)
        defaults.set(currentVersion, forKey: lastVersionKey)
        defaults.set(Date(), forKey: lastDateKey)
        defaults.set(0, forKey: actionCountKey)
    }
}
