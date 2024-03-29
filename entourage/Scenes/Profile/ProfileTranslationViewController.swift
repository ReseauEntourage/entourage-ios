//
//  ProfileTranslationViewController.swift
//  entourage
//
//  Created by Clement entourage on 26/10/2023.
//

import Foundation
import UIKit

class ProfileTranslationViewController:UIViewController {
    
    @IBOutlet weak var ui_label_language: UILabel!
    
    
    override func viewDidLoad() {
        ui_label_language.text = "onboarding_lang_select".localized
    }
    
    @IBAction func onValidateClick(_ sender: Any) {
    }
    
}
