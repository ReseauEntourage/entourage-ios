//
//  UIKit+Stylable.swift
//  entourage
//
//  Created by Veronica on 02/05/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

import Foundation

extension UIButton {
    func apply(style: ButtonStyles) {
        setTitleColor(style.textColor, for: .normal)
        backgroundColor = style.backgroundColor
        layer.borderColor = style.borderColor.cgColor
        layer.borderWidth = 1.0
    }
}

extension UILabel {
    func apply(style: LabelStyles) {
        textColor = style.textColor
        font = style.font
        backgroundColor = style.backgroundColor
    }
}
