//
//  OTOnboardingAssoStartViewController.swift
//  entourage
//
//  Created by Jr on 25/05/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTOnboardingAssoStartViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_label_description2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_label_title.text =  "onboard_asso_start_title".localized
        ui_label_description2.text =  "onboard_asso_start_description2".localized
        ui_label_description.attributedText = Utils.formatString(stringMessage:  "onboard_asso_start_description".localized, coloredTxt:  "onboard_asso_start_description_bold".localized, color: .appBlack30, colorHighlight: UIColor.appOrange, fontSize: 22, fontWeight: .light, fontColoredWeight: .bold)
        
//        OTLogger.logEvent(View_Onboarding_Pro_Stories) //TODO:  Analytics
    }
}
