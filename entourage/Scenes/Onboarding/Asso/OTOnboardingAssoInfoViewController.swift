//
//  OTOnboardingAssoInfoViewController.swift
//  entourage
//
//  Created by Jr on 25/05/2020.
//  Copyright © 2020 Entourage. All rights reserved.
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

       ui_label_title.text =  "onboard_asso_info_title".localized
       ui_label_description.text =  "onboard_asso_info_description".localized
       
        ui_label_info_1.attributedText = Utils.formatString(stringMessage:  "onboard_asso_info_1".localized, coloredTxt:  "onboard_asso_info_1_bold".localized, color: .appBlack30, colorHighlight: .appBlack30, fontSize: 14, fontWeight: .regular, fontColoredWeight: .bold)
        ui_label_info_2.attributedText = Utils.formatString(stringMessage:  "onboard_asso_info_2".localized, coloredTxt:  "onboard_asso_info_2_bold".localized, color: .appBlack30, colorHighlight: .appBlack30, fontSize: 14, fontWeight: .regular, fontColoredWeight: .bold)
        ui_label_info_3.attributedText = Utils.formatString(stringMessage:  "onboard_asso_info_3".localized, coloredTxt:  "onboard_asso_info_3_bold".localized, color: .appBlack30, colorHighlight: .appBlack30, fontSize: 14, fontWeight: .regular, fontColoredWeight: .bold)
        
//        OTLogger.logEvent(View_Onboarding_Pro_Features) //TODO:  Analytics
    }
}
