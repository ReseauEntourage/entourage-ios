//
//  File.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

import Foundation

enum ButtonStyles {
    case whiteRounded
    case navButton
    case whiteRoundedWithBorder
}

extension ButtonStyles: ComponentStylable {
    var isUnderlined: Bool {
        return false
    }
    
    var font: UIFont {
        switch self {
        case .whiteRounded, .whiteRoundedWithBorder:
            return UIFont.SFUIText(size: 7, type: .bold)
        case .navButton:
            return UIFont.SFUIText(size: 12, type: .semibold)
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .whiteRounded, .whiteRoundedWithBorder:
            return UIColor.appBlue()
        case .navButton:
            return .clear
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .whiteRounded, .whiteRoundedWithBorder:
            return UIColor.appBlue()
        case .navButton:
            return .white
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .whiteRounded, .whiteRoundedWithBorder:
            return .white
        case .navButton:
            return UIColor.appBlue()
        }
    }
}
