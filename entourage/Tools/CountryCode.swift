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
    CountryCode(country: "Guadeloupe", code: "+590", flag: "🇫🇷"),
    CountryCode(country: "Martinique", code: "+596", flag: "🇫🇷"),
    CountryCode(country: "Guyane", code: "+594", flag: "🇫🇷"),
    CountryCode(country: "La Réunion", code: "+262", flag: "🇫🇷"),
    CountryCode(country: "Mayotte", code: "+262", flag: "🇫🇷"),
    CountryCode(country: "Polynésie", code: "+689", flag: "🇫🇷"),
    CountryCode(country: "Nouvelle-Calédonie", code: "+687", flag: "🇫🇷"),
    CountryCode(country: "Saint-Martin / St-Barth", code: "+590", flag: "🇫🇷"),
]
