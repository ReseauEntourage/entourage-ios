//
//  UIFont+Extensions.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

@objc enum dynamicStyle: Int {
	case largeTitle // 0
	case title1     // 1
	case title2     // 2
	case title3     // 3
	case headline   // 4
	case body       // 5
	case callout    // 6
	case subhead    // 7
	case footnote   // 8
	case caption1   // 9
	case caption2   // 10
	
	var size: CGFloat {
		switch self {
		case .largeTitle:
			return 30
		case .title1:
			return 28
		case .title2:
			return 22
		case .title3:
			return 20
		case .headline,
			 .body:
			return 17
		case .callout:
			return 16
		case .subhead:
			return 15
		case .footnote:
			return 13
		case .caption1:
			return 12
		case .caption2:
			return 11
		}
	}
	
	var type: SFUITextFontType {
		switch self {
		case .largeTitle,
			 .title2:
			return .semibold
		default:
			return .regular
		}
	}
}

@objc enum SFUITextFontType: Int {
	case bold
	case regular
	case semibold
	case medium
	case light

	var string: String {
		switch self {
		case .bold:
			return "-Bold"
		case .regular:
			return "-Regular"
		case .semibold:
			return "-Semibold"
		case .medium:
			return "-Medium"
		case .light:
			return "-Light"
		}
	}
}

@objc extension UIFont {
    @objc static func SFUIText(size: CGFloat, type: SFUITextFontType = .regular) -> UIFont {
        guard let font = UIFont(name: "SFUIText" + type.string, size: size) else {
            assertionFailure("Missing font")
            return UIFont.systemFont(ofSize: size)
        }
        return FontMetrics.scaledFont(for: font)
    }
}
