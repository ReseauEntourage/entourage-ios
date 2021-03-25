//
//  OTHomeHelpViewController.swift
//  entourage
//
//  Created on 24/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeHelpViewController: UIViewController {

    @IBOutlet weak var ui_title_bt_1: UILabel!
    @IBOutlet weak var ui_title_bt_2: UILabel!
    @IBOutlet weak var ui_title_bt_3: UILabel!
    @IBOutlet weak var ui_title_bt_4: UILabel!
    @IBOutlet weak var ui_title_bt_5: UILabel!
    
    @IBOutlet weak var ui_button_1: UIButton!
    @IBOutlet weak var ui_button_2: UIButton!
    @IBOutlet weak var ui_button_3: UIButton!
    @IBOutlet weak var ui_button_4: UIButton!
    @IBOutlet weak var ui_button_5: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_help_title")
        ui_title_bt_1.text = OTLocalisationService.getLocalizedValue(forKey: "home_help_bt_1")
        ui_title_bt_2.text = OTLocalisationService.getLocalizedValue(forKey: "home_help_bt_2")
        ui_title_bt_3.text = OTLocalisationService.getLocalizedValue(forKey: "home_help_bt_3")
        ui_title_bt_4.text = OTLocalisationService.getLocalizedValue(forKey: "home_help_bt_4")
        ui_title_bt_5.text = OTLocalisationService.getLocalizedValue(forKey: "home_help_bt_5")
        
        
        ui_button_2.tag = 1
        ui_button_3.tag = 2
        ui_button_4.tag = 3
        ui_button_5.tag = 4
    }
    
    @IBAction func action_show_reporter(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "HomeHelpReporter") {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func action_show_links(_ sender: UIButton) {
        let url1 = GIFT_URL //"https://entourage.iraiser.eu/jedonne/~mon-don"
        let url3 = JOIN_URL //"https://www.entourage.social/devenir-ambassadeur/"
        let url2 = ABOUT_FACEBOOK_URL // "https://www.facebook.com/EntourageReseauCivique/"
        let url4 = ABOUT_LINKEDOUT //"https://www.linkedout.fr/"
        
        switch sender.tag {
        case 1:
            if let url = URL.init(string: url1) {
                OTSafariService.launchInAppBrowser(with: url)
            }
            break
        case 2:
            if let url = URL.init(string: url2) {
                OTSafariService.launchInAppBrowser(with: url)
            }
            break
        case 3:
            if let url = URL.init(string: url3) {
                OTSafariService.launchInAppBrowser(with: url)
            }
            break
        case 4:
            if let url = URL.init(string: url4) {
                OTSafariService.launchInAppBrowser(with: url)
            }
            break
            
        default:
            break
        }
    }
}
