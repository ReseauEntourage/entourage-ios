//
//  EnhancedOnboardingEnd.swift
//  entourage
//
//  Created by Clement entourage on 24/05/2024.
//

import Foundation
import UIKit
import Lottie

class EnhancedOnboardingEnd:UIViewController{
    
    //Outlet
    @IBOutlet weak var ui_lottiview: LottieAnimationView!
    @IBOutlet weak var ui_title_label: UILabel!
    @IBOutlet weak var ui_subtitle_label: UILabel!
    @IBOutlet weak var ui_btn_go_event: UIButton!
    
    
    //Variable
    
    
    override func viewDidLoad() {
        let starAnimation = LottieAnimation.named("congrats_animation")
        ui_lottiview.animation = starAnimation
        ui_lottiview.loopMode = .loop
        ui_lottiview.play()
        ui_title_label.text = "enhanced_onboarding_end_title".localized
        ui_subtitle_label.text = "enhanced_onboarding_end_subtitle".localized
        
        configureOrangeButton(ui_btn_go_event, withTitle: "enhanced_onboarding_button_title_event".localized)
        ui_btn_go_event.addTarget(self, action: #selector(onEventClick), for: .touchUpInside)
        let config = EnhancedOnboardingConfiguration.shared
        if config.isOnboardingFromSetting{
            configureOrangeButton(ui_btn_go_event, withTitle: "button_title_for_re_onboarding_end".localized)
        }
    }
    
    @objc func onEventClick(){
        let config = EnhancedOnboardingConfiguration.shared
        if config.isOnboardingFromSetting{
            self.dismiss(animated: true) {
                config.isOnboardingFromSetting = false
            }
        }else{
            AppState.navigateToMainApp()
        }
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    func presentViewControllerWithAnimation(identifier: String) {
            let storyboard = UIStoryboard(name: "EnhancedViewController", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? UIViewController {
                viewController.modalPresentationStyle = .fullScreen
                viewController.modalTransitionStyle = .coverVertical
                present(viewController, animated: true, completion: nil)
            }
        }
}
