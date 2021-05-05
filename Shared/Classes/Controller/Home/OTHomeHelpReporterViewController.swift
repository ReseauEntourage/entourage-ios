//
//  OTHomeHelpReporterViewController.swift
//  entourage
//
//  Created on 24/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTHomeHelpReporterViewController: UIViewController {
    
    @IBOutlet weak var ui_title_bt: UILabel!
    @IBOutlet weak var ui_tv_description: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_help_reporter_title")
        self.ui_tv_description.text = OTLocalisationService.getLocalizedValue(forKey: "home_help_reporter_desc")
    }
    
    @IBAction func action_show_web(_ sender: Any) {
        let url = "https://entourage-asso.typeform.com/to/xVBzfaVd"
        if let _url = URL.init(string: url) {
            OTSafariService.launchInAppBrowser(with: _url)
        }
    }
}
