//
//  OTProfileSelectActions2ViewController.swift
//  entourage
//
//  Created by Jr on 22/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTProfileSelectActionsViewController: UIViewController {
    
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
    var activitiesAssoSelections:AssoActivities? = nil
    var username = ""
    var isSdf = true
    var isAsso = false
    
    var userTypeSelected = UserType.none
    
    var validateButton:UIBarButtonItem? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch userTypeSelected {
        case .neighbour:
            isAsso = false
            isSdf = false
            OTLogger.logEvent(View_Profile_Neighbor_Mosaic)
        case .alone:
            isAsso = false
            isSdf = true
            OTLogger.logEvent(View_Profile_InNeed_Mosaic)
        case .assos:
            isAsso = true
            isSdf = false
            OTLogger.logEvent(View_Profile_Pro_Mosaic)
        default:
            break
        }
        
        prepareViews()
        setupTexts()
        setupImages()
        updateButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addButtonValidate()
    }
    
    func addButtonValidate() {
        validateButton = UIBarButtonItem.init(title: "Valider", style: .done, target: self, action: #selector(validateType))
        validateButton?.isEnabled = false
        self.navigationItem.rightBarButtonItem = validateButton
    }
    
    @objc func validateType() {
        sendActions()
    }
    
    //MARK: - Methods -
    
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
        
        if isAsso {
            ui_view_choice_5.isHidden = true
            ui_view_choice_6.isHidden = true
        }
        else if isSdf {
            ui_view_choice_6.layer.cornerRadius = 4
            ui_view_choice_6.layer.borderWidth = 1
            ui_view_choice_6.layer.borderColor = UIColor.appWhite246.cgColor
        }
        else {
            ui_view_choice_6_inside.isHidden = true
            ui_view_choice_6.backgroundColor = .white
        }
        
        if view.frame.height <= 568 {
            ui_main_stackview.spacing = 10
            if isAsso {
                ui_constraint_view_height.constant = 107
            }
            else {
                ui_constraint_view_height.constant = 90
            }
            
            ui_main_stackview.spacing = 10
            ui_constraint_spacing_description.constant = 8
            ui_label_title.font = ui_label_title.font.withSize(15)
        }
    }
    
    func setupTexts() {
        
        if isAsso {
            ui_label_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "profile_asso_activity_title"),username)
            ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_description")
            
            ui_label_choice_1.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_1")
            ui_label_choice_2.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_2")
            ui_label_choice_3.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_3")
            ui_label_choice_4.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_asso_activity_choice_4")
            
            return
        }
        
        let _titleKey = isSdf ? "profile_sdf_activity_title" : "profile_neighbour_activity_title"
        let _descKey = isSdf ? "profile_sdf_activity_description" : "onboard_neighbour_activity_description"
        ui_label_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: _titleKey),username)
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: _descKey)
        Logger.print("Nom de l'user ? \(username)")
        let _choice1Key = isSdf ? "onboard_sdf_activity_choice_1" : "onboard_neighbour_activity_choice_1"
        let _choice2Key = isSdf ? "onboard_sdf_activity_choice_2" : "onboard_neighbour_activity_choice_2"
        let _choice3Key = isSdf ? "onboard_sdf_activity_choice_3" : "onboard_neighbour_activity_choice_3"
        let _choice4Key = isSdf ? "onboard_sdf_activity_choice_4" : "onboard_neighbour_activity_choice_4"
        let _choice5Key = isSdf ? "onboard_sdf_activity_choice_5" : "onboard_neighbour_activity_choice_5"
        let _choice6Key = "onboard_sdf_activity_choice_6"
        ui_label_choice_1.text = OTLocalisationService.getLocalizedValue(forKey: _choice1Key)
        ui_label_choice_2.text = OTLocalisationService.getLocalizedValue(forKey: _choice2Key)
        ui_label_choice_3.text = OTLocalisationService.getLocalizedValue(forKey: _choice3Key)
        ui_label_choice_4.text = OTLocalisationService.getLocalizedValue(forKey: _choice4Key)
        ui_label_choice_5.text = OTLocalisationService.getLocalizedValue(forKey: _choice5Key)
        ui_label_choice_6.text = OTLocalisationService.getLocalizedValue(forKey: _choice6Key)
    }
    
    func setupImages() {
        if isAsso {
            ui_iv_choice_1.image = UIImage.init(named: "onboard_picto_aide")
            ui_iv_choice_2.image = UIImage.init(named: "onboard_picto_culture")
            ui_iv_choice_3.image = UIImage.init(named: "onboard_picto_investir")
            ui_iv_choice_4.image = UIImage.init(named: "onboard_picto_autre")
            return
        }
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
        
        self.activitiesSelections = activitiesSelections
        
        updateButtons()
    }
    
    func changeSelectionAssoViewPosition(_ position:Int) {
        
        if activitiesAssoSelections == nil {
            activitiesAssoSelections = AssoActivities()
        }
        
        var activitiesSelections = self.activitiesAssoSelections!
        
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
        
        self.activitiesAssoSelections = activitiesSelections
        
        updateButtons()
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
    
    func updateButtons() {
        if isAsso {
            if let _activities = self.activitiesAssoSelections, _activities.hasOneSelectionMin() {
                validateButton?.isEnabled = true
            }
            else {
                validateButton?.isEnabled = false
            }
            return
        }
        
        if let _activities = self.activitiesSelections, _activities.hasOneSelectionMin() {
            validateButton?.isEnabled = true
        }
        else {
            validateButton?.isEnabled = false
        }
    }
    
    //MARK: - Network -
    
    func sendActions() {
        updateGoalType()
    }
    
    func updateActivities() {
        SVProgressHUD.show()
        
        switch userTypeSelected {
        case .neighbour:
            OTLogger.logEvent(Action_Profile_Neighbor_Mosaic)
        case .alone:
            OTLogger.logEvent(Action_Profile_InNeed_Mosaic)
        case .assos:
            OTLogger.logEvent(Action_Profile_Pro_Mosaic)
        default:
            break
        }
        
        let _array = isAsso ? activitiesAssoSelections?.getArrayForWS() : activitiesSelections?.getArrayForWS()
        OTAuthService().updateUserInterests(_array,success: { (user) in
            let _currentUser = UserDefaults.standard.currentUser
            user?.phone = _currentUser?.phone
            UserDefaults.standard.currentUser = user
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.popToProfile()
            }
        }) { (error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.popToProfile()
            }
        }
    }
    
    func updateGoalType() {
        SVProgressHUD.show()
        let _currentUser = UserDefaults.standard.currentUser
        _currentUser?.goal = userTypeSelected.getGoalString()
        
        if userTypeSelected != .none {
            OTLogger.logEvent(Action_Profile_Choose_Profile_Signup)
        }
        
        OTAuthService().updateUserInformation(with: _currentUser, success: { (newUser) in
            newUser?.phone = _currentUser?.phone
            UserDefaults.standard.currentUser = newUser
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.updateActivities()
            }
        }) { (error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.updateActivities()
            }
        }
    }
    
    func popToProfile() {
        if let _navController = self.navigationController {
            for vc in _navController.viewControllers {
                if vc.isKind(of: OTUserEditViewController.classForCoder()) {
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
    //MARK: - IBActions -
    
    @IBAction func action_tap_choice_1(_ sender: Any) {
        if isAsso {
            changeSelectionAssoViewPosition(1)
            return
        }
        changeSelectionViewPosition(1)
    }
    @IBAction func action_tap_choice_2(_ sender: Any) {
        if isAsso {
            changeSelectionAssoViewPosition(2)
            return
        }
        changeSelectionViewPosition(2)
    }
    @IBAction func action_tap_choice_3(_ sender: Any) {
        if isAsso {
            changeSelectionAssoViewPosition(3)
            return
        }
        changeSelectionViewPosition(3)
    }
    @IBAction func action_tap_choice_4(_ sender: Any) {
        if isAsso {
            changeSelectionAssoViewPosition(4)
            return
        }
        changeSelectionViewPosition(4)
    }
    @IBAction func action_tap_choice_5(_ sender: Any) {
        changeSelectionViewPosition(5)
    }
    @IBAction func action_tap_choice_6(_ sender: Any) {
        changeSelectionViewPosition(6)
    }
    
}
