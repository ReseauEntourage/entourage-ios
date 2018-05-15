//
//  LabelStyles.swift
//  entourage
//
//  Created by Veronica on 03/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

import Foundation

enum LabelStyles {
    case boldGray
}

extension LabelStyles: ComponentStylable {
    var font: UIFont {
        switch self {
        case .boldGray:
            return UIFont.SFUIText(size: 16, type: .bold)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .boldGray:
            return UIColor.pfpGrayText()
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .boldGray:
            return UIColor.pfpTableBackground()
        }
    }
    
    var borderColor: UIColor {
        return UIColor.clear
    }
    
    var isUnderlined: Bool {
        return false
    }
    
    
}
