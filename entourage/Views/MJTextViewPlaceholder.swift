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
    var hasToCenterTextVerticaly = false
    
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
        let result = super.becomeFirstResponder()
        if result {
            DispatchQueue.main.async {
                if #available(iOS 13.0, *) {
                    UIMenuController.shared.showMenu(from: self, rect: self.bounds)
                } else {
                    UIMenuController.shared.setTargetRect(self.bounds, in: self)
                    UIMenuController.shared.setMenuVisible(true, animated: true)
                }
            }
        }
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        if text.isEmpty {
            showPlaceholderText()
        }
        return super.resignFirstResponder()
    }
    
    // Use to center verticaly text -
    // https://stackoverflow.com/questions/12591192
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if hasToCenterTextVerticaly {
            let rect = layoutManager.usedRect(for: textContainer)
            let topInset = (bounds.size.height - rect.height) / 2.0
            textContainerInset.top = max(0, topInset)
        }
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
