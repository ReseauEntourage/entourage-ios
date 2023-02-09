//
//  Extension_UILabel.swift
//  entourage
//
//  Created by Clement entourage on 01/02/2023.
//

import Foundation
import ActiveLabel

extension UILabel{
    
    func makeClickable(withTarget target: Any?, andAction action: Selector?) {
            self.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: target, action: action)
            self.addGestureRecognizer(tapGesture)
        }
    
}
