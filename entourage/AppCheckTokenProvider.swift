//
//  AppCheckTokenProvider.swift
//  entourage
//
//  Created by Clement entourage on 09/12/2025.
//

import Foundation
import GooglePlaces
import FirebaseAppCheck

@available(iOS 13.0, *)
final class AppCheckTokenProvider: NSObject, GMSPlacesAppCheckTokenProvider {
    func fetchAppCheckToken() async throws -> String {
        // Récupère un token App Check Firebase et le renvoie à Places
        let token = try await AppCheck.appCheck().token(forcingRefresh: false)
        print("eho token debbug: ", token)
        return token.token
    }
}
