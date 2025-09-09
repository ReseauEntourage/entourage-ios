//
//  AppSignableManager.swift
//  entourage
//
//  Created by Clement entourage on 09/09/2025.
//

import Foundation

final class AppSignableManager {
    static let shared = AppSignableManager()

    var signablePermission: Bool = false
    var signableEvent: Bool = false

    private init() {} // Empêche l'initialisation externe

    func updateFromHome(userHome: UserHome) {
        self.signablePermission = userHome.signablePermission ?? false
    }
    func updateFromEvent(event: Event) {
        self.signableEvent = event.signable ?? false
    }
}
