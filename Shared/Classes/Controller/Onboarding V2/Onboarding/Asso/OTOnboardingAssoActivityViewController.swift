//
//  OTOnboardingAssoActivityViewController.swift
//  entourage
//
//  Created by Jr on 25/05/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingAssoActivityViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    
    @IBOutlet weak var ui_view_choice_1: UIView!
    @IBOutlet weak var ui_view_choice_2: UIView!
    @IBOutlet weak var ui_view_choice_3: UIView!
    @IBOutlet weak var ui_view_choice_4: UIView!
    
    @IBOutlet weak var ui_label_choice_1: UILabel!
    @IBOutlet weak var ui_label_choice_2: UILabel!
    @IBOutlet weak var ui_label_choice_3: UILabel!
    @IBOutlet weak var ui_label_choice_4: UILabel!
    
    var activitiesSelections:AssoActivities? = nil
    var username = ""
    
    weak var delegate:OnboardV2Delegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_label_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_title"),username)
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_description")
        
        ui_label_choice_1.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_1")
        ui_label_choice_2.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_2")
        ui_label_choice_3.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_3")
        ui_label_choice_4.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_4")
        
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
        
        if let _activities = activitiesSelections, _activities.hasOneSelectionMin() {
            delegate?.updateButtonNext(isValid: true)
            changeColors(view: ui_view_choice_1, label: ui_label_choice_1, isSelected: activitiesSelections!.choice1Selected)
            changeColors(view: ui_view_choice_2, label: ui_label_choice_2, isSelected: activitiesSelections!.choice2Selected)
            changeColors(view: ui_view_choice_3, label: ui_label_choice_3, isSelected: activitiesSelections!.choice3Selected)
            changeColors(view: ui_view_choice_4, label: ui_label_choice_4, isSelected: activitiesSelections!.choice4Selected)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
    }
    
    func changeSelectionViewPosition(_ position:Int) {
        
        if activitiesSelections == nil {
            activitiesSelections = AssoActivities()
        }
        
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
        default:
            break
        }
        delegate?.updateAssoActivities(assoActivities: activitiesSelections)
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
            _view.layer.borderColor = UIColor.appOrange().cgColor
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
}

struct AssoActivities {
    var choice1Selected = false
    var choice2Selected = false
    var choice3Selected = false
    var choice4Selected = false
    
    func hasOneSelectionMin() -> Bool {
        if choice1Selected || choice2Selected || choice3Selected || choice4Selected {
            return true
        }
        
        return false
    }
    
    mutating func reset() {
        choice1Selected = false
        choice2Selected = false
        choice3Selected = false
        choice4Selected = false
    }
    
    func getArrayForWS() -> [String] {
        var _array = [String]()
        if choice1Selected {
            _array.append("aide_pers_asso")
        }
        if choice2Selected {
            _array.append("cult_sport_asso")
        }
        if choice3Selected {
            _array.append("serv_pub_asso")
        }
        if choice4Selected {
            _array.append("autre_asso")
        }
        
        return _array
    }
}
