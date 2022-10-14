//
//  OTOnboardingSDFNeighbourActivityViewController.swift
//  entourage
//
//  Created by Jr on 11/06/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTOnboardingSDFNeighbourActivityViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    
    @IBOutlet weak var ui_view_choice_1: UIView!
    @IBOutlet weak var ui_view_choice_2: UIView!
    @IBOutlet weak var ui_view_choice_3: UIView!
    @IBOutlet weak var ui_view_choice_4: UIView!
    @IBOutlet weak var ui_view_choice_5: UIView!
    @IBOutlet weak var ui_view_choice_6: UIView!
    @IBOutlet weak var ui_view_choice_6_inside: UIView!
    @IBOutlet weak var ui_iv_choice_1: UIImageView!
    
    @IBOutlet weak var ui_iv_choice_2: UIImageView!
    @IBOutlet weak var ui_iv_choice_3: UIImageView!
    @IBOutlet weak var ui_iv_choice_4: UIImageView!
    @IBOutlet weak var ui_iv_choice_5: UIImageView!
    @IBOutlet weak var ui_iv_choice_6: UIImageView!
    @IBOutlet weak var ui_label_choice_1: UILabel!
    @IBOutlet weak var ui_label_choice_2: UILabel!
    @IBOutlet weak var ui_label_choice_3: UILabel!
    @IBOutlet weak var ui_label_choice_4: UILabel!
    @IBOutlet weak var ui_label_choice_5: UILabel!
    @IBOutlet weak var ui_label_choice_6: UILabel!
    
    @IBOutlet weak var ui_main_stackview: UIStackView!
    @IBOutlet weak var ui_constraint_view_height: NSLayoutConstraint!
    
    @IBOutlet weak var ui_constraint_spacing_description: NSLayoutConstraint!
    
    var activitiesSelections:SdfNeighbourActivities? = nil
    var username = ""
    var isSdf = true
    
    weak var delegate:OnboardV2Delegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareViews()
        setupTexts()
        setupImages()
        
        if view.frame.height <= 568 {
            ui_constraint_view_height.constant = 90
            ui_main_stackview.spacing = 10
            ui_constraint_spacing_description.constant = 8
            ui_label_title.font = ui_label_title.font.withSize(15)
        }
        
        if let _activities = activitiesSelections, _activities.hasOneSelectionMin() {
            delegate?.updateButtonNext(isValid: true)
            changeColors(view: ui_view_choice_1, label: ui_label_choice_1, isSelected: activitiesSelections!.choice1Selected)
            changeColors(view: ui_view_choice_2, label: ui_label_choice_2, isSelected: activitiesSelections!.choice2Selected)
            changeColors(view: ui_view_choice_3, label: ui_label_choice_3, isSelected: activitiesSelections!.choice3Selected)
            changeColors(view: ui_view_choice_4, label: ui_label_choice_4, isSelected: activitiesSelections!.choice4Selected)
            changeColors(view: ui_view_choice_5, label: ui_label_choice_5, isSelected: activitiesSelections!.choice5Selected)
            if isSdf {
                changeColors(view: ui_view_choice_6, label: ui_label_choice_6, isSelected: activitiesSelections!.choice6Selected)
            }
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
        
        if isSdf {
//            OTLogger.logEvent(View_Onboarding_InNeed_Mosaic)//TODO:  Analytics
        }
        else {
//            OTLogger.logEvent(View_Onboarding_Neighbor_Mosaic)//TODO:  Analytics
        }
        
    }
    
    func prepareViews() {
        ui_view_choice_1.layer.cornerRadius = 4
        ui_view_choice_1.layer.borderWidth = 1
        ui_view_choice_1.layer.borderColor = UIColor.appWhite246.cgColor
        ui_view_choice_2.layer.cornerRadius = 4
        ui_view_choice_2.layer.borderWidth = 1
        ui_view_choice_2.layer.borderColor = UIColor.appWhite246.cgColor
        ui_view_choice_3.layer.cornerRadius = 4
        ui_view_choice_3.layer.borderWidth = 1
        ui_view_choice_3.layer.borderColor = UIColor.appWhite246.cgColor
        ui_view_choice_4.layer.cornerRadius = 4
        ui_view_choice_4.layer.borderWidth = 1
        ui_view_choice_4.layer.borderColor = UIColor.appWhite246.cgColor
        ui_view_choice_5.layer.cornerRadius = 4
        ui_view_choice_5.layer.borderWidth = 1
        ui_view_choice_5.layer.borderColor = UIColor.appWhite246.cgColor
        
        if isSdf {
            ui_view_choice_6.layer.cornerRadius = 4
            ui_view_choice_6.layer.borderWidth = 1
            ui_view_choice_6.layer.borderColor = UIColor.appWhite246.cgColor
        }
        else {
             ui_view_choice_6_inside.isHidden = true
            ui_view_choice_6.backgroundColor = .white
        }
        
    }
    
    func setupTexts() {
        let _titleKey = isSdf ? "onboard_sdf_activity_title" : "onboard_neighbour_activity_title"
        let _descKey = isSdf ? "onboard_sdf_activity_description" : "onboard_neighbour_activity_description"
        ui_label_title.text = String.init(format:  _titleKey.localized,username)
        ui_label_description.text =  _descKey.localized
        Logger.print("Nom de l'user ? \(username)")
        let _choice1Key = isSdf ? "onboard_sdf_activity_choice_1" : "onboard_neighbour_activity_choice_1"
        let _choice2Key = isSdf ? "onboard_sdf_activity_choice_2" : "onboard_neighbour_activity_choice_2"
        let _choice3Key = isSdf ? "onboard_sdf_activity_choice_3" : "onboard_neighbour_activity_choice_3"
        let _choice4Key = isSdf ? "onboard_sdf_activity_choice_4" : "onboard_neighbour_activity_choice_4"
        let _choice5Key = isSdf ? "onboard_sdf_activity_choice_5" : "onboard_neighbour_activity_choice_5"
        let _choice6Key = "onboard_sdf_activity_choice_6"
        ui_label_choice_1.text =  _choice1Key.localized
        ui_label_choice_2.text =  _choice2Key.localized
        ui_label_choice_3.text =  _choice3Key.localized
        ui_label_choice_4.text =  _choice4Key.localized
        ui_label_choice_5.text =  _choice5Key.localized
        ui_label_choice_6.text =  _choice6Key.localized
    }
    
    func setupImages() {
        let _iv1 = isSdf ? "icn_sdf_circle" : "icn_neighbour_info"
        let _iv2 = isSdf ? "icn_sdf_events" : "icn_neighbour_events"
        let _iv3 = isSdf ? "icn_sdf_question" : "icn_neighbour_entourer"
        let _iv4 = isSdf ? "icn_sdf_help" : "icn_neighbour_gift"
        let _iv5 = isSdf ? "icn_sdf_orienter" : "icn_neighbour_investir"
        let _iv6 = "icn_sdf_search"
        ui_iv_choice_1.image = UIImage.init(named: _iv1)
        ui_iv_choice_2.image = UIImage.init(named: _iv2)
        ui_iv_choice_3.image = UIImage.init(named: _iv3)
        ui_iv_choice_4.image = UIImage.init(named: _iv4)
        ui_iv_choice_5.image = UIImage.init(named: _iv5)
        ui_iv_choice_6.image = UIImage.init(named: _iv6)
    }
    
    func changeSelectionViewPosition(_ position:Int) {
        
        if activitiesSelections == nil {
            activitiesSelections = SdfNeighbourActivities()
        }
        self.activitiesSelections?.isSdf = self.isSdf
        var activitiesSelections = self.activitiesSelections!
        
        switch position {
        case 1:
            activitiesSelections.choice1Selected = !activitiesSelections.choice1Selected
            changeColors(view: ui_view_choice_1, label: ui_label_choice_1, isSelected: activitiesSelections.choice1Selected)
        case 2:
            activitiesSelections.choice2Selected = !activitiesSelections.choice2Selected
            changeColors(view: ui_view_choice_2, label: ui_label_choice_2, isSelected: activitiesSelections.choice2Selected)
        case 3:
            activitiesSelections.choice3Selected = !activitiesSelections.choice3Selected
            changeColors(view: ui_view_choice_3, label: ui_label_choice_3, isSelected: activitiesSelections.choice3Selected)
        case 4:
            activitiesSelections.choice4Selected = !activitiesSelections.choice4Selected
            changeColors(view: ui_view_choice_4, label: ui_label_choice_4, isSelected: activitiesSelections.choice4Selected)
        case 5:
            activitiesSelections.choice5Selected = !activitiesSelections.choice5Selected
            changeColors(view: ui_view_choice_5, label: ui_label_choice_5, isSelected: activitiesSelections.choice5Selected)
        case 6:
            activitiesSelections.choice6Selected = !activitiesSelections.choice6Selected
            changeColors(view: ui_view_choice_6, label: ui_label_choice_6, isSelected: activitiesSelections.choice6Selected)
        default:
            break
        }
        
        if isSdf {
            delegate?.updateSdfActivities(sdfActivities: activitiesSelections)
        }
        else {
            delegate?.updateNeighbourActivities(neighbourActivities: activitiesSelections)
        }
        
        self.activitiesSelections = activitiesSelections
        
        if let _activities = self.activitiesSelections, _activities.hasOneSelectionMin() {
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
    }
    
    func changeColors(view _view:UIView,label _label:UILabel,isSelected:Bool) {
        if isSelected {
            _view.backgroundColor = .white
            _view.layer.borderColor = UIColor.appOrange.cgColor
            _label.font = UIFont.systemFont(ofSize: _label.font.pointSize, weight: .bold)
        }
        else {
            _view.backgroundColor = .appWhite246
            _view.layer.borderColor = UIColor.appWhite246.cgColor
            _label.font = UIFont.systemFont(ofSize: _label.font.pointSize, weight: .regular)
        }
    }
    
    
    @IBAction func action_tap_choice_1(_ sender: Any) {
        changeSelectionViewPosition(1)
    }
    @IBAction func action_tap_choice_2(_ sender: Any) {
        changeSelectionViewPosition(2)
    }
    @IBAction func action_tap_choice_3(_ sender: Any) {
        changeSelectionViewPosition(3)
    }
    @IBAction func action_tap_choice_4(_ sender: Any) {
        changeSelectionViewPosition(4)
    }
    @IBAction func action_tap_choice_5(_ sender: Any) {
        changeSelectionViewPosition(5)
    }
    @IBAction func action_tap_choice_6(_ sender: Any) {
        changeSelectionViewPosition(6)
    }
    
}


struct SdfNeighbourActivities {
    var choice1Selected = false
    var choice2Selected = false
    var choice3Selected = false
    var choice4Selected = false
    var choice5Selected = false
    var choice6Selected = false
    
    var isSdf = true
    
    init() {
        choice1Selected = false
        choice2Selected = false
        choice3Selected = false
        choice4Selected = false
        choice5Selected = false
        choice6Selected = false
    }
    
    init(isSdf:Bool) {
        self.isSdf = isSdf
        choice1Selected = true
        choice2Selected = true
        choice3Selected = true
        choice4Selected = true
        choice5Selected = true
        
        if self.isSdf {
            choice6Selected = true
        }
    }
    
    func hasOneSelectionMin() -> Bool {
        if isSdf {
            if choice1Selected || choice2Selected || choice3Selected || choice4Selected || choice5Selected || choice6Selected {
                return true
            }
        }
        else {
            if choice1Selected || choice2Selected || choice3Selected || choice4Selected || choice5Selected {
                return true
            }
        }
        
        
        return false
    }
    
    mutating func reset() {
        choice1Selected = false
        choice2Selected = false
        choice3Selected = false
        choice4Selected = false
        choice5Selected = false
        choice6Selected = false
    }
    
    func getArrayForWS() -> [String] {
        var _array = [String]()
        if choice1Selected {
            let _choice = isSdf ? "rencontrer_sdf" : "m_informer_riverain"
            _array.append(_choice)
        }
        if choice2Selected {
            let _choice = isSdf ? "event_sdf" : "event_riverain"
            _array.append(_choice)
        }
        if choice3Selected {
            let _choice = isSdf ? "questions_sdf" : "entourer_riverain"
            _array.append(_choice)
        }
        if choice4Selected {
            let _choice = isSdf ? "aide_sdf" : "dons_riverain"
            _array.append(_choice)
        }
        if choice5Selected {
            let _choice = isSdf ? "m_orienter_sdf" : "benevolat_riverain"
            _array.append(_choice)
        }
        if choice6Selected {
            let _choice = "trouver_asso_sdf"
            _array.append(_choice)
        }
        
        return _array
    }
}
