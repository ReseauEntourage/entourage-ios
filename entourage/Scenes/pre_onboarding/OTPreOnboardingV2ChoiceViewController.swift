//
//  OTPreOnboardingV2ChoiceViewController.swift
//  entourage
//
//  Created by Jr on 14/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTPreOnboardingV2ChoiceViewController: UIViewController {
    @IBOutlet weak var ui_bt_signup_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_login_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_link_constraint_height: NSLayoutConstraint!
    
    @IBOutlet weak var ui_bt_link: UIButton!
    @IBOutlet weak var ui_bt_login: UIButton!
    @IBOutlet weak var ui_bt_signup: UIButton!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_constraint_top_image: NSLayoutConstraint!
    
    var isFromOnboarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_description.text =  "preOnboard_choice_description".localized
        ui_bt_login.setTitle( "preOnboard_choice_login".localized, for: .normal)
        ui_bt_signup.setTitle( "preOnboard_choice_signup".localized, for: .normal)
        
        ui_bt_signup.layer.cornerRadius = ui_bt_signup.frame.height / 2
        
        ui_bt_login.layer.cornerRadius = ui_bt_login.frame.height / 2
   
        ui_label_description.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange(size: 24))
        
        ui_bt_signup.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc(size: 15))
        ui_bt_login.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange(size: 15))
        
        ui_bt_link.setAttributedTitle(Utils.formatStringUnderline(textString: "preOnboard_choice_weblink".localized, textColor: .appOrange, font: ApplicationTheme.getFontNunitoBold(size: 15)), for: .normal)
        
        if view.frame.height <= 568 {
            ui_constraint_top_image.constant = -50
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hideTransparentNavigationBar()
        UserDefaults.temporaryUser = nil
        
        if isFromOnboarding {
            self.isFromOnboarding = false
            self.action_login(self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.presentTransparentNavigationBar()
    }
    
    //MARK: - IBActions
    @IBAction func action_show_weblink(_ sender: Any) {
        if let url = URL.init(string: ENTOURAGE_WEB_URL) {
            SafariWebManager.launchUrlInApp(url: url, viewController: self.navigationController)
        }
    }
    
    @IBAction func action_signUp(_ sender: Any) {
        let sb = UIStoryboard.init(name: StoryboardName.onboarding, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "onboardingStart") as! OnboardingStartViewController
        vc.parentDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func action_login(_ sender: Any) {
        let vc = UIStoryboard(name: StoryboardName.intro, bundle: nil).instantiateViewController(withIdentifier: "LoginV2VC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
