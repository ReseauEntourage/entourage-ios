//
//  EnahancedOnboardingButtonCell.swift
//  entourage
//
//  Created by Clement entourage on 23/05/2024.
//

import Foundation
import UIKit

protocol EnhancedOnboardingButtonDelegate{
    func onConfigureLaterClick()
    func onNextClick()
}
class EnahancedOnboardingButtonCell:UITableViewCell{
    
    //Outlet
    @IBOutlet weak var ui_btn_configure_later: UIButton!
    @IBOutlet weak var ui_btn_next: UIButton!
    
    //Variable
    var delegate:EnhancedOnboardingButtonDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Default configuration
        configureOrangeButton(ui_btn_next, withTitle: "enhanced_onboarding_button_title_next".localized)
        configureWhiteButton(ui_btn_configure_later, withTitle: "enhanced_onboarding_button_title_later".localized)
    }
    
    func configure(isSettings: Bool, isLastStep: Bool) {
        ui_btn_configure_later.addTarget(self, action: #selector(onConfigureLaterClick), for: .touchUpInside)
        ui_btn_next.addTarget(self, action: #selector(onBtnNextClick), for: .touchUpInside)

        if isSettings {
            // Settings: Annuler / Valider
            configureOrangeButton(ui_btn_next, withTitle: "validate".localized)
            configureWhiteButton(ui_btn_configure_later, withTitle: "cancel".localized)
        } else {
            // Onboarding
            let nextTitle = isLastStep ? "action_create_close_button".localized : "enhanced_onboarding_button_title_next".localized
            let laterTitle = "enhanced_onboarding_button_title_later".localized

            configureOrangeButton(ui_btn_next, withTitle: nextTitle)
            configureWhiteButton(ui_btn_configure_later, withTitle: laterTitle)
        }
    }

    func configure() {
        // Fallback for compatibility if needed, though we should prefer the explicit method
        configure(isSettings: false, isLastStep: false)
    }
    
    func configureForMainFilter() {
        configure(isSettings: true, isLastStep: false)
    }
    
    @objc func onConfigureLaterClick(){
        delegate?.onConfigureLaterClick()
        
    }
    
    @objc func onBtnNextClick(){
        delegate?.onNextClick()
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
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
}
