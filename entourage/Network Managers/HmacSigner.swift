//
//  HmacSigner.swift
//  entourage
//

import CryptoKit
import Foundation

struct HmacSigner {

    /// Signe la requête de création de compte.
    /// Retourne nil si aucun secret n'est configuré (mode transition : la vérification
    /// côté backend est désactivée pour les clés sans hmac_secret).
    static func signCreateAccount(phone: String) -> (timestamp: String, signature: String)? {
        let secret = EnvironmentConfigurationManager.sharedInstance.HmacSecret
        guard !secret.isEmpty else { return nil }

        let timestamp = Int(Date().timeIntervalSince1970)
        let message = "POST\n/api/v1/users\n\(timestamp)\n\(phone)"

        guard let keyData = secret.data(using: .utf8) else { return nil }
        let key = SymmetricKey(data: keyData)
        let code = HMAC<SHA256>.authenticationCode(
            for: Data(message.utf8),
            using: key
        )
        let signature = Data(code).base64EncodedString()

        return (timestamp: String(timestamp), signature: signature)
    }
}
