//
//  OTCustomTextfield.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTCustomTextfield: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    private var titleToolBar = OTLocalisationService.getLocalizedValue(forKey: "close")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.appWhite246
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return UIEdgeInsetsInsetRect(bounds, padding)
    }

    var hasDoneButton:Bool = false {
        didSet {
            if hasDoneButton {
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func activateToolBarWithTitle(_ title:String? = nil) {
        titleToolBar = title != nil ? title! : titleToolBar
        hasDoneButton = true
    }
    
   private func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        doneToolbar.barTintColor = ApplicationTheme.shared().backgroundThemeColor

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: titleToolBar, style: .plain, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}
