//
//  DiscussionSmokeTestViewController.swift
//  entourage
//
//  Created by Clement entourage on 06/08/2024.
//

import Foundation
import UIKit

class DiscussionSmokeTestViewController: UIViewController {
    
    
    // OUTLET
  
    @IBOutlet weak var ui_btn_validate: UIButton!
    
    @IBOutlet weak var ui_btn_cross: UIButton!
    @IBOutlet weak var ui_btn_deny: UILabel!
    
    // VARIABLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add actions for the buttons and label
        ui_btn_validate.addTarget(self, action: #selector(validateButtonTapped), for: .touchUpInside)
        ui_btn_cross.addTarget(self, action: #selector(denyAction), for: .touchUpInside)
        
        let denyLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(denyAction))
        ui_btn_deny.isUserInteractionEnabled = true
        ui_btn_deny.addGestureRecognizer(denyLabelTapGesture)
        setUnderlineTextForDenyButton()

    }
    
    @objc func validateButtonTapped() {
        // Store the value in UserDefaults
        UserDefaults.standard.set(true, forKey: "HasAcceptedDiscussion")
        
        // Show alert dialog
        let alertController = UIAlertController(title: "Super ,", message: "toast_message_participate".localized, preferredStyle: .alert)
        
        // Add a dismiss button
        let quitAction = UIAlertAction(title: "Quitter", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(quitAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func denyAction() {
        // Store the value in UserDefaults
        UserDefaults.standard.set(true, forKey: "HasDeniedDiscussion")
        
        // Dismiss the view controller
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUnderlineTextForDenyButton() {
        let text = NSLocalizedString("popup_discussion_test_btn_cancel", comment: "")
        
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length)
        
        // Add underline attribute
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        
        ui_btn_deny.attributedText = attributedString
    }
}
