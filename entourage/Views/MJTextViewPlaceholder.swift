//
//  MJTextviewPlaceholder.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

@IBDesignable class MJTextViewPlaceholder: UITextView {
    
    @IBInspectable var placeholderText: String = ""
    @IBInspectable var placeholderColor: UIColor = UIColor(red: 199 / 255, green: 199 / 255, blue: 199 / 255, alpha: 1.0) // light grey default
    
    private var showingPlaceholder = true
    
    override var text: String! {
        get {
            if showingPlaceholder {
                return ""
            } else {
                return super.text
            }
        }
        
        set {
            showingPlaceholder = false
            if let _newvalue = newValue, (_newvalue.isEmpty || _newvalue == placeholderText) {
                showingPlaceholder = true
            }
            super.text = newValue
        }
    }
    
    //MARK: - Overrides -
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if text.isEmpty {
            showPlaceholderText()
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        if showingPlaceholder {
            hidePlaceholder()
        }
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if text.isEmpty {
            showPlaceholderText()
        }
        return super.resignFirstResponder()
    }
    
    //MARK: - Private show / hide placeholder -
    private func hidePlaceholder() {
        text = nil
        textColor = nil
        showingPlaceholder = false
    }
    
    private func showPlaceholderText() {
        showingPlaceholder = true
        textColor = placeholderColor
        text = placeholderText
    }
}
