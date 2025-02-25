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
        configureOrangeButton(ui_btn_next, withTitle: "enhanced_onboarding_button_title_next".localized)
        configureWhiteButton(ui_btn_configure_later, withTitle: "enhanced_onboarding_button_title_later".localized)
        let config = EnhancedOnboardingConfiguration.shared
        if config.isInterestsFromSetting{
            configureOrangeButton(ui_btn_next, withTitle: "button_title_for_setting_onboarding".localized)
        }
    }
    
    func configure(){
        ui_btn_configure_later.addTarget(self, action: #selector(onConfigureLaterClick), for: .touchUpInside)
        self.ui_btn_next.setTitle("validate".localized, for: .normal)
        self.ui_btn_configure_later.setTitle("cancel".localized, for: .normal)
        ui_btn_next.addTarget(self, action: #selector(onBtnNextClick), for: .touchUpInside)
    }
    
    func configureForMainFilter(){
        self.configure()
        self.ui_btn_next.setTitle("btn_main_filter_validate_title".localized, for: .normal)
        self.ui_btn_configure_later.setTitle("cancel".localized, for: .normal)
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
