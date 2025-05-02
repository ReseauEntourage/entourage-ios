//
//  Extensions_UITextField.swift
//  entourage
//
//  Created by Jerome on 07/04/2022.
//

import Foundation


extension UITextField {
    func addToolBar(width _width:CGFloat, buttonValidate:UIBarButtonItem) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: _width, height: 30))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //Custom font and color
        let fontColor = UIColor.appOrange
        let fontName = ApplicationTheme.getFontCourantRegularNoir().font
        buttonValidate.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: fontColor, NSAttributedString.Key.font: fontName], for: .normal)
        toolbar.setItems([flexSpace, buttonValidate], animated: false)
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
}

extension UITextView {
    func addToolBar(width _width:CGFloat, buttonValidate:UIBarButtonItem) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: _width, height: 30))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //Custom font and color
        let fontColor = UIColor.appOrange
        let fontName = ApplicationTheme.getFontCourantRegularNoir().font
        buttonValidate.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: fontColor, NSAttributedString.Key.font: fontName], for: .normal)
        toolbar.setItems([flexSpace, buttonValidate], animated: false)
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
}

extension UITextField {
    func setPlaceholder(text: String, font: UIFont, color: UIColor = .lightGray) {
        self.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color
            ]
        )
    }
}
