//
//  OTPreOnboardingV2ChoiceViewController.swift
//  entourage
//
//  Created by Jr on 14/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTPreOnboardingV2ChoiceViewController: UIViewController {
    @IBOutlet weak var ui_logo_constraint_top: NSLayoutConstraint!
    @IBOutlet weak var ui_logo_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_link_constrait_top: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_signup_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_login_constraint_height: NSLayoutConstraint!
    @IBOutlet weak var ui_bt_link_constraint_height: NSLayoutConstraint!
    
    @IBOutlet weak var ui_bt_link: UIButton!
    @IBOutlet weak var ui_bt_login: UIButton!
    @IBOutlet weak var ui_bt_signup: UIButton!
    @IBOutlet weak var ui_label_description: UILabel!
    
    var isFromOnboarding = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_description.text =  "preOnboard_choice_description".localized
        ui_bt_link.setTitle( "preOnboard_choice_weblink".localized, for: .normal)
        ui_bt_login.setTitle( "preOnboard_choice_login".localized.uppercased(), for: .normal)
        ui_bt_signup.setTitle( "preOnboard_choice_signup".localized.uppercased(), for: .normal)
        
        ui_bt_signup.layer.cornerRadius = 8
        ui_bt_login.layer.cornerRadius = 8
        ui_bt_login.layer.borderWidth = 2
        ui_bt_login.layer.borderColor = UIColor.appOrange.cgColor
        
        if view.frame.height == 736 {
            ui_logo_constraint_top.constant = 20
            ui_logo_constraint_height.constant = 140
            ui_link_constrait_top.constant = 20
            self.view.layoutIfNeeded()
        }
        else if view.frame.height <= 667 {
            ui_logo_constraint_top.constant = 20
            ui_logo_constraint_height.constant = 100
            ui_link_constrait_top.constant = 20
            
            if view.frame.height <= 568 {
                ui_logo_constraint_height.constant = 80
                ui_bt_signup_constraint_height.constant = 40
                ui_bt_login_constraint_height.constant = 40
                ui_bt_link_constraint_height.constant = 40
            }
            self.view.layoutIfNeeded()
        }
       // OTLogger.logEvent(View_Start_SignUpLogin)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     //   OTAppConfiguration.configureNavigationControllerAppearance(self.navigationController)
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
//        OTLogger.logEvent(Action_Start_LoginStart)//TODO: - a faire
        
        let vc = UIStoryboard(name: StoryboardName.intro, bundle: nil).instantiateViewController(withIdentifier: "LoginV2VC")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
