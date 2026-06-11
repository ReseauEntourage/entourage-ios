import Foundation
import SwiftUI

class BadgesViewModel: ObservableObject {
    @Published var badges: [Badge] = []
    @Published var isLoading = true
    @Published var error: Error?

    // We mock the badge info as the back doesn't send progression/dates yet in most environments
    // But we still parse and merge with the known keys to map them correctly.

    // All known badges
    let allBadgeKeys = [
        "premier_contact",
        "bienvenue",
        "moteur_rencontres",
        "fidele_papotages",
        "voix_presente"
    ]

    func fetchBadges() {
        self.isLoading = true
        HomeService.getUserHome { [weak self] userHome, error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.error = error
                return
            }

            if let fetchedBadges = userHome?.badges {
                // Merge fetched badges with our known full list
                var mergedBadges = [Badge]()

                let fetchedNames = Set(fetchedBadges.map { $0.name })

                for key in self.allBadgeKeys {
                    if let fetchedBadge = fetchedBadges.first(where: { $0.name == key }) {
                        mergedBadges.append(fetchedBadge)
                    } else {
                        // Badge not started
                        mergedBadges.append(Badge(name: key, date: nil, progression: 0))
                    }
                }

                self.badges = mergedBadges
            } else {
                // If userHome?.badges is nil, populate with empty badges
                self.badges = self.allBadgeKeys.map { Badge(name: $0, date: nil, progression: 0) }
            }
        }
    }

    var hasAnyProgression: Bool {
        return badges.contains(where: { $0.date != nil || ($0.progression ?? 0) > 0 })
    }

    var obtainedBadges: [Badge] {
        return badges.filter { $0.date != nil }
    }

    var inProgressBadges: [Badge] {
        return badges.filter { $0.date == nil && ($0.progression ?? 0) > 0 }
    }

    var notStartedBadges: [Badge] {
        return badges.filter { $0.date == nil && ($0.progression ?? 0) == 0 }
    }
}
