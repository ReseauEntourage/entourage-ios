//
//  Translations.swift
//  entourage
//
//  Created by Clement entourage on 04/12/2023.
//

import Foundation

struct Translations: Codable {
    var translation: String? = nil
    var original: String? = nil
    var from_lang: String? = nil
    var to_lang: String? = nil

    enum CodingKeys: String, CodingKey {
        case translation
        case original
        case from_lang = "from_lang"
        case to_lang = "to_lang"
    }
}
