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
        let timestamp = Int(Date().timeIntervalSince1970)
        let message = "POST\n/api/v1/users\n\(timestamp)\n\(phone)"
        return sign(message: message, timestamp: timestamp)
    }

    /// Signe un appel API générique (méthode + chemin + timestamp + corps de requête).
    /// Utilisé pour tous les appels autres que la création de compte.
    /// Retourne nil si aucun secret n'est configuré (mode transition, cf. `signCreateAccount`).
    static func sign(method: String, path: String, body: Data?) -> (timestamp: String, signature: String)? {
        let timestamp = Int(Date().timeIntervalSince1970)
        let bodyString = body.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        let message = "\(method)\n\(path)\n\(timestamp)\n\(bodyString)"
        return sign(message: message, timestamp: timestamp)
    }

    private static func sign(message: String, timestamp: Int) -> (timestamp: String, signature: String)? {
        let secret = EnvironmentConfigurationManager.sharedInstance.HmacSecret
        guard !secret.isEmpty, let keyData = secret.data(using: .utf8) else { return nil }

        let key = SymmetricKey(data: keyData)
        let code = HMAC<SHA256>.authenticationCode(
            for: Data(message.utf8),
            using: key
        )
        let signature = Data(code).base64EncodedString()

        Logger.print("[HmacSigner] HMAC KEY: [\(secret)] MESSAGE: [\(message)] SIGNATURE: [\(signature)]")

        return (timestamp: String(timestamp), signature: signature)
    }
}
