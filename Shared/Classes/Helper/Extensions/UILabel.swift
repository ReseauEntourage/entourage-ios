//
//  UILabel.swift
//  entourage
//
//  Created by Work on 02/01/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

import UIKit

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
			self.font = .SFUIText(size: newValue.size, type: newValue.type)
        }
    }
    
    @objc func underline() {
        let underlineAttribute = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: underlineAttribute)
    }
}
