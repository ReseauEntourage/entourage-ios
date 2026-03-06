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
    public init(country: String, code: String, flag: String) {
        self.country = country; self.code = code; self.flag = flag
    }
}

// Source de vérité unique
public let defaultCountryCode = CountryCode(country: "France", code: "+33", flag: "🇫🇷")

// Optionnel : liste réutilisable
public let allCountryCodes: [CountryCode] = [
    CountryCode(country: "France",   code: "+33", flag: "🇫🇷"),
    CountryCode(country: "Belgique", code: "+32", flag: "🇧🇪"),
]
