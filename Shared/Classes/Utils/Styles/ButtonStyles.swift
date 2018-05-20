//
//  File.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

enum ButtonStyles {
    case whiteRounded
    case navButton
}

extension ButtonStyles: ComponentStylable {
    var isUnderlined: Bool {
        return false
    }
    
    var font: UIFont {
        switch self {
        case .whiteRounded:
            return UIFont.SFUIText(size: 7, type: .bold)
        case .navButton:
            return UIFont.SFUIText(size: 12, type: .semibold)
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .whiteRounded:
            return UIColor.pfpBlue()
        case .navButton:
            return .clear
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .whiteRounded:
            return UIColor.pfpBlue()
        case .navButton:
            return .white
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .whiteRounded:
            return .white
        case .navButton:
            return UIColor.pfpBlue()
        }
    }
}
