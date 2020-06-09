//
//  OTOnboardingAssoStartViewController.swift
//  entourage
//
//  Created by Jr on 25/05/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingAssoStartViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_label_description2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_start_title")
        ui_label_description2.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_start_description2")
        ui_label_description.attributedText = Utilitaires.formatString(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_start_description"), coloredTxt: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_start_description_bold"), color: .appBlack30, colorHighlight: UIColor.appOrange(), fontSize: 22, fontWeight: .light, fontColoredWeight: .bold)
        
        OTLogger.logEvent(View_Onboarding_Pro_Stories)
    }
}
