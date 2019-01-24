//
//  UIFont+Extensions.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

@objc enum dynamicStyle: Int {
	case largeTitle 		// 0
	case title1     		// 1
	case title2     		// 2
	case title3    			// 3
	case headline   		// 4
	case body       		// 5
	case callout    		// 6
	case subhead    		// 7
	case footnote   		// 8
	case caption1   		// 9
	case caption2   		// 10
	case title1Bold     	// 11
	case title2Bold     	// 12
	case title3Bold     	// 13
	case headlineBold   	// 14
	case bodyBold       	// 15
	case calloutBold    	// 16
	case subheadBold    	// 17
	case footnoteBold   	// 18
	case caption1Bold   	// 19
	case caption2Bold   	// 20
	case title1Semibold     // 21
	case title2Semibold     // 22
	case title3Semibold     // 23
	case headlineSemibold   // 24
	case bodySemibold       // 25
	case calloutSemibold    // 26
	case subheadSemibold    // 27
	case footnoteSemibold   // 28
	case caption1Semibold   // 29
	case caption2Semibold   // 30
	case title1Medium     	// 31
	case title2Medium     	// 32
	case title3Medium     	// 33
	case headlineMedium   	// 34
	case bodyMedium       	// 35
	case calloutMedium    	// 36
	case subheadMedium    	// 37
	case footnoteMedium   	// 38
	case caption1Medium   	// 39
	case caption2Medium   	// 40
	case title1Light     	// 41
	case title2Light     	// 42
	case title3Light     	// 43
	case headlineLight   	// 44
	case bodyLight       	// 45
	case calloutLight    	// 46
	case subheadLight    	// 47
	case footnoteLight   	// 48
	case caption1Light   	// 49
	case caption2Light   	// 50

	var size: CGFloat {
		switch self {
		case .largeTitle:
			return 30
		case .title1,
			 .title1Bold,
			 .title1Semibold,
			 .title1Medium,
			 .title1Light:
			return 28
		case .title2,
			 .title2Bold,
			 .title2Semibold,
			 .title2Medium,
			 .title2Light:
			return 22
		case .title3,
			 .title3Bold,
			 .title3Semibold,
			 .title3Medium,
			 .title3Light:
			return 20
		case .headline,
			 .headlineBold,
			 .headlineSemibold,
			 .headlineMedium,
			 .headlineLight,
			 .body,
			 .bodyBold,
			 .bodySemibold,
			 .bodyMedium,
			 .bodyLight:
			return 17
		case .callout,
			 .calloutBold,
			 .calloutSemibold,
			 .calloutMedium,
			 .calloutLight:
			return 16
		case .subhead,
			 .subheadBold,
			 .subheadSemibold,
			 .subheadMedium,
			 .subheadLight:
			return 15
		case .footnote,
			 .footnoteBold,
			 .footnoteSemibold,
			 .footnoteMedium,
			 .footnoteLight:
			return 13
		case .caption1,
			 .caption1Bold,
			 .caption1Semibold,
			 .caption1Medium,
			 .caption1Light:
			return 12
		case .caption2,
			 .caption2Bold,
			 .caption2Semibold,
			 .caption2Medium,
			 .caption2Light:
			return 11
		}
	}
	
	var type: SFUITextFontType {
		switch self {
		case .title1Bold,
			 .title2Bold,
			 .title3Bold,
			 .headlineBold,
			 .bodyBold,
			 .calloutBold,
			 .subheadBold,
			 .footnoteBold,
			 .caption1Bold,
			 .caption2Bold:
			return .bold
		case .largeTitle,
			 .title1Semibold,
			 .title2Semibold,
			 .title3Semibold,
			 .headlineSemibold,
			 .bodySemibold,
			 .calloutSemibold,
			 .subheadSemibold,
			 .footnoteSemibold,
			 .caption1Semibold,
			 .caption2Semibold:
			return .semibold
		case .title1Medium,
			 .title2Medium,
			 .title3Medium,
			 .headlineMedium,
			 .bodyMedium,
			 .calloutMedium,
			 .subheadMedium,
			 .footnoteMedium,
			 .caption1Medium,
			 .caption2Medium:
			return .medium
		case .title1Light,
			 .title2Light,
			 .title3Light,
			 .headlineLight,
			 .bodyLight,
			 .calloutLight,
			 .subheadLight,
			 .footnoteLight,
			 .caption1Light,
			 .caption2Light:
			return .light
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
