//
//  OTOnboardingTypeViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingTypeViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_label_description2: UILabel!
    
    @IBOutlet weak var ui_view_1: UIView!
    @IBOutlet weak var ui_label_view_1: UILabel!
    @IBOutlet weak var ui_label_title_view_1: UILabel!
    @IBOutlet weak var ui_view_2: UIView!
    @IBOutlet weak var ui_label_view_2: UILabel!
    @IBOutlet weak var ui_label_title_view_2: UILabel!
    @IBOutlet weak var ui_view_3: UIView!
    @IBOutlet weak var ui_label_view_3: UILabel!
    @IBOutlet weak var ui_label_title_view_3: UILabel!
    
    weak var delegate:OnboardV2Delegate? = nil
    
    var userTypeSelected = UserType.none
    var firstname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareViews()
        
        if self.userTypeSelected != .none {
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
        
        OTLogger.logEvent(View_Onboarding_Choose_Profile)
    }
    
    func prepareViews() {
        addCornerAndColorBorder(toView: ui_view_1)
        addCornerAndColorBorder(toView: ui_view_2)
        addCornerAndColorBorder(toView: ui_view_3)
        
        selectInitialButtonSelected()
        
        ui_label_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_type_title"), firstname)
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_sub")
        
        ui_label_description2.text = ""
        
        ui_label_view_1.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice1")
        ui_label_view_2.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice2")
        ui_label_view_3.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice3")
        
        ui_label_title_view_1.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice_title1")
        ui_label_title_view_2.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice_title2")
        ui_label_title_view_3.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_type_choice_title3")
    }
    
    func selectInitialButtonSelected() {
        switch userTypeSelected {
        case .neighbour:
            changeBorderAndBackgroundColor(toView: ui_view_1, isSelected: true)
        case .alone:
            changeBorderAndBackgroundColor(toView: ui_view_2, isSelected: true)
        case .assos:
            changeBorderAndBackgroundColor(toView: ui_view_3, isSelected: true)
        default:
            break
        }
    }
    
    func addCornerAndColorBorder(toView _view:UIView) {
        _view.layer.cornerRadius = 4
        _view.layer.borderWidth = 1
        _view.layer.borderColor = UIColor.appWhite246.cgColor
        _view.backgroundColor = UIColor.appWhite246
    }
    
    func changeBorderAndBackgroundColor(toView _view:UIView, isSelected:Bool = false) {
        _view.layer.borderColor = isSelected ? UIColor.appOrange()?.cgColor : UIColor.appWhite246.cgColor
        _view.backgroundColor = isSelected ? UIColor.white : UIColor.appWhite246
    }
    
    func updateDelegate() {
        delegate?.updateUserType(userType: userTypeSelected)
        delegate?.updateButtonNext(isValid: true)
    }
    
    //MARK: - IBActions -
    @IBAction func action_tap_view1(_ sender: Any) {
        userTypeSelected = .neighbour
        changeBorderAndBackgroundColor(toView: ui_view_1, isSelected: true)
        changeBorderAndBackgroundColor(toView: ui_view_2)
        changeBorderAndBackgroundColor(toView: ui_view_3)
        updateDelegate()
    }
    @IBAction func action_tap_view2(_ sender: Any) {
        userTypeSelected = .alone
        changeBorderAndBackgroundColor(toView: ui_view_2, isSelected: true)
        changeBorderAndBackgroundColor(toView: ui_view_1)
        changeBorderAndBackgroundColor(toView: ui_view_3)
        updateDelegate()
    }
    @IBAction func action_tap_view3(_ sender: Any) {
        userTypeSelected = .assos
        changeBorderAndBackgroundColor(toView: ui_view_3, isSelected: true)
        changeBorderAndBackgroundColor(toView: ui_view_1)
        changeBorderAndBackgroundColor(toView: ui_view_2)
        updateDelegate()
    }
}
