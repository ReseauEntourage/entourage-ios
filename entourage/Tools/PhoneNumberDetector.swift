import Foundation

/// Détecte la présence d'un numéro de téléphone français dans un texte (EN-8022).
/// Utilisé côté client pour avertir qu'un échange sort du réseau sécurisé d'Entourage.
enum PhoneNumberDetector {

    /// Formats couverts : 06 12 34 56 78, 0612345678, 06.12.34.56.78, 06-12-34-56-78,
    /// +33 6 12 34 56 78, +33612345678, +33 (0)6…, 0033612345678.
    /// Les séparateurs peuvent être des espaces (y compris insécables), points ou tirets.
    private static let pattern = #"(?<![\d+])(?:(?:\+|00)33[  .\-]*(?:\(0\)[  .\-]*)?0?|0)[1-9](?:[  .\-]*\d{2}){4}(?!\d)"#

    private static let regex = try? NSRegularExpression(pattern: pattern)

    /// Plages (en UTF-16, utilisables directement avec NSAttributedString) des numéros français du texte.
    static func findFrenchPhoneNumbers(in text: String?) -> [NSRange] {
        guard let text, !text.isEmpty, let regex else { return [] }
        let range = NSRange(location: 0, length: (text as NSString).length)
        return regex.matches(in: text, options: [], range: range).map { $0.range }
    }

    static func containsPhoneNumber(_ text: String?) -> Bool {
        return !findFrenchPhoneNumbers(in: text).isEmpty
    }
}
