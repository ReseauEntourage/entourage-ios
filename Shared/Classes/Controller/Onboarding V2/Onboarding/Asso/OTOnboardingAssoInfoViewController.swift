//
//  OTOnboardingAssoInfoViewController.swift
//  entourage
//
//  Created by Jr on 25/05/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingAssoInfoViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info_1: UILabel!
    @IBOutlet weak var ui_label_info_2: UILabel!
    @IBOutlet weak var ui_label_info_3: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_title")
       ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_description")
       
        ui_label_info_1.attributedText = Utilitaires.formatString(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_1"), coloredTxt: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_1_bold"), color: .appBlack30, colorHighlight: .appBlack30, fontSize: 14, fontWeight: .regular, fontColoredWeight: .bold)
        ui_label_info_2.attributedText = Utilitaires.formatString(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_2"), coloredTxt: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_2_bold"), color: .appBlack30, colorHighlight: .appBlack30, fontSize: 14, fontWeight: .regular, fontColoredWeight: .bold)
        ui_label_info_3.attributedText = Utilitaires.formatString(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_3"), coloredTxt: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_info_3_bold"), color: .appBlack30, colorHighlight: .appBlack30, fontSize: 14, fontWeight: .regular, fontColoredWeight: .bold)
        
        OTLogger.logEvent(View_Onboarding_Pro_Features)
    }
}
