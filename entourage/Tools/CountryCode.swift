//
//  CountryCode.swift
//  entourage
//
//  Created by Clement entourage on 14/10/2025.
//

import Foundation

public struct CountryCode: Equatable {
    public let country: String
    public let code: String
    public let flag: String
    public let exampleNumber: String

    public init(country: String, code: String, flag: String, exampleNumber: String = "06 XX XX XX XX") {
        self.country = country; self.code = code; self.flag = flag; self.exampleNumber = exampleNumber
    }
}

// Source de vérité unique
public let defaultCountryCode = CountryCode(country: "France", code: "+33", flag: "🇫🇷", exampleNumber: "06 XX XX XX XX")

// Optionnel : liste réutilisable
public let allCountryCodes: [CountryCode] = [
    CountryCode(country: "France",     code: "+33",  flag: "🇫🇷", exampleNumber: "06 XX XX XX XX"),
    CountryCode(country: "Belgique",   code: "+32",  flag: "🇧🇪", exampleNumber: "04XX XX XX XX"),
    CountryCode(country: "La Réunion", code: "+262", flag: "🇷🇪", exampleNumber: "06 XX XX XX XX"),
    CountryCode(country: "Guadeloupe", code: "+590", flag: "🇬🇵", exampleNumber: "06 XX XX XX XX"),
    CountryCode(country: "Maroc",      code: "+212", flag: "🇲🇦", exampleNumber: "06 XX XX XX XX"),
]
