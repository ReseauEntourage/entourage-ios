//
//  UIFont+Extensions.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

extension UIFont {
    static func SFUIText(size: CGFloat, type: SFUITextFontType = .regular) -> UIFont {
        guard let font = UIFont(name: "SFUIText" + type.rawValue, size: size) else {
            assertionFailure("Missing font")
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    enum SFUITextFontType: String {
        case bold = "-Bold"
        case regular = "-Regular"
        case semibold = "-Semibold"
        case medium = "-Medium"
        case light = "-Light"
    }
}
