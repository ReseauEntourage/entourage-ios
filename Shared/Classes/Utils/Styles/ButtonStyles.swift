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
}

extension ButtonStyles: ComponentStylable {
    var isUnderlined: Bool {
        return false
    }
    
    var font: UIFont {
        return UIFont.SFUIText(size: 7, type: .bold)
    }
    
    var borderColor: UIColor {
        return UIColor.pfpBlue()
    }
    
    var textColor: UIColor {
        return UIColor.pfpBlue()
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .whiteRounded:
            return .white
        }
    }
}
