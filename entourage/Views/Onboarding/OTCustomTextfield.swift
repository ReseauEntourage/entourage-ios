//
//  OTCustomTextfield.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTCustomTextfield: UITextField {
    static let validateNotif = "validate"
    
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    private var titleToolBar =  "close".localized
    
    var buttonToolBar:UIBarButtonItem? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.backgroundColor = UIColor.appWhite246
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.inset(by: padding)
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
       //TODO: a mod
        //doneToolbar.barTintColor = ApplicationTheme.shared().primaryNavigationBarTintColor

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        buttonToolBar = UIBarButtonItem(title: titleToolBar, style: .plain, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, buttonToolBar!]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: OTCustomTextfield.validateNotif), object: nil)
        self.resignFirstResponder()
    }
}
