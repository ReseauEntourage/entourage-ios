//
//  UILabel.swift
//  entourage
//
//  Created by Work on 02/01/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

import UIKit

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
            return 34
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
}

@objc extension UILabel {
    
    var dynamicStyle: dynamicStyle {
        get {
            return self.dynamicStyle
        }
        set(newValue) {
            if #available(iOS 10.0, *) {
                self.adjustsFontForContentSizeCategory = true
            } else {
                // Fallback on earlier versions
            }
            self.font = .SFUIText(size: newValue.size)
        }
    }
    
    @objc func underline() {
        let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: underlineAttribute)
    }
}
