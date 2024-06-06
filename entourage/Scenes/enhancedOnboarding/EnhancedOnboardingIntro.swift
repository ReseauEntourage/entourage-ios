//
//  EnhancedOnboardingIntro.swift
//  entourage
//
//  Created by Clement entourage on 24/05/2024.
//

import Foundation
import UIKit

class EnhancedOnboardingIntro:UIViewController{
    
    //Outlet
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_subtitle: UILabel!
    @IBOutlet weak var ui_btn_start: UIButton!
    @IBOutlet weak var ui_btn_later: UIButton!
    
    //Variable
    
    override func viewDidLoad() {
        if let _user = UserDefaults.currentUser{
            ui_title.text = String.init(format: "enhanced_onboarding_start_title".localized, _user.firstname )
            ui_subtitle.text = String.init(format: "enhanced_onboarding_start_subtitle".localized, _user.firstname )
            configureOrangeButton(ui_btn_start, withTitle: "enhanced_onboarding_button_title_start".localized)
            configureWhiteButton(ui_btn_later, withTitle: "enhanced_onboarding_button_title_configlater".localized)
        }
        self.ui_btn_later.addTarget(self, action: #selector(onConfigureLaterClick), for: .touchUpInside)
        self.ui_btn_start.addTarget(self, action: #selector(onStartClick), for: .touchUpInside)
    }
    
    @objc func onConfigureLaterClick(){
        AppState.navigateToMainApp()
    }

    @objc func onStartClick(){
        presentViewControllerWithAnimation(identifier: "enhancedOnboarding")
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 24
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        button.clipsToBounds = true
    }
    
    func presentViewControllerWithAnimation(identifier: String) {
        let storyboard = UIStoryboard(name: "EnhancedOnboarding", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? EnhancedViewController {
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .coverVertical
            present(viewController, animated: true, completion: nil)
        }
    }

}
