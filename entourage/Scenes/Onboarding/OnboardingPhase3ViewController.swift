//
//  OnboardingPhase3ViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import CoreLocation
import GooglePlaces

protocol Phase3fromAppDelegate{
    func updatePreference(userType:UserType)
    func updateLoc(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    func sendOnboardingEnd()
}

enum OnboardingPhase3DTO {
    case titleCell
    case userTypeCell(choice: OnboardingChoice, isSelected:Bool, subtitle:String)
    case adressCell
}

class OnboardingPhase3ViewController: UIViewController {

    @IBOutlet weak var ui_tableview: UITableView!
    
    @IBOutlet weak var ui_next_btn: UIButton!
    
    weak var pageDelegate:OnboardingDelegate? = nil
    var fromAppDelegate:Phase3fromAppDelegate? = nil
    
    var location_new:CLLocationCoordinate2D? = nil
    var location_name_new:String? = nil
    var location_googlePlace_new:GMSPlace? = nil
    
    var isEntour = false
    var isBeEntour = false
    var isBoth = false
    var isAsso = false
    
    var userTypeSelected = UserType.none
    var tableDTO = [OnboardingPhase3DTO]()
    
    
    override func viewDidLoad() {
        self.ui_next_btn.isOpaque = true
        self.ui_next_btn.addTarget(self, action: #selector(onNextClick), for: .touchUpInside)
        configureOrangeButton(self.ui_next_btn, withTitle: "next".localized)
        ui_tableview.allowsSelection = true
        ui_tableview.delegate = self
        ui_tableview.dataSource = self
        
        ui_tableview.register(UINib(nibName: OnboardingPhase3TitleCell.identifier, bundle: nil), forCellReuseIdentifier: OnboardingPhase3TitleCell.identifier)
        ui_tableview.register(UINib(nibName: OnboardingPhase3MapCell.identifier, bundle: nil), forCellReuseIdentifier: OnboardingPhase3MapCell.identifier)
        ui_tableview.register(UINib(nibName: "EnhancedFullSizeCell", bundle: nil), forCellReuseIdentifier: "fullSizeCell")
        loadDTO()
    }
    
    func loadDTO(){
        self.tableDTO.removeAll()
        let choice1 = OnboardingChoice(id: "entour", img: "ic_onboarding_three_entour", title: NSLocalizedString("onboarding_phase_three_option_entourer", comment:""))
        let choice2 = OnboardingChoice(id: "been_entour", img: "ic_onboarding_three_been_entour", title: NSLocalizedString("onboarding_phase_three_option_etre_entoure", comment: ""))
        let choice3 = OnboardingChoice(id: "both", img: "ic_onboarding_three_both", title: NSLocalizedString("onboarding_phase_three_option_les_deux", comment: ""))

        tableDTO.append(.titleCell)
        tableDTO.append(.userTypeCell(choice: choice1, isSelected: self.isEntour, subtitle: "onboarding_phase_three_option_entourer_description".localized))
        tableDTO.append(.userTypeCell(choice: choice2, isSelected: self.isBeEntour, subtitle: "onboarding_phase_three_option_etre_entoure_description".localized))
        tableDTO.append(.userTypeCell(choice: choice3, isSelected: self.isBoth, subtitle: "onboarding_phase_three_option_les_deux_description".localized))
        tableDTO.append(.adressCell)
        
        self.ui_tableview.reloadData()
    }
    
    @objc func onNextClick(){
        self.dismiss(animated: false) {
            self.fromAppDelegate?.sendOnboardingEnd()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.ui_next_btn.isOpaque = true
        
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
      }
    
    func updateUserType() {
        EnhancedOnboardingConfiguration.shared.shouldNotDisplayCampain = true
        if(isBeEntour){
            EnhancedOnboardingConfiguration.shared.preference = "contribution"
        }
        var userType = UserType.none
        if isBeEntour {
            userType = .alone
        }
        else if isEntour {
            userType = .neighbour
        }
        
        if(isBoth){
            userType = .both
        }
       
        if isAsso {
            userType = .assos
        }
        if let fromAppDelegate{
            fromAppDelegate.updatePreference(userType: userType)
        }else{
            pageDelegate?.addInfos(userType: userType)

        }
        if (isBeEntour || isAsso || isEntour) && location_name_new != nil {
            self.ui_next_btn.isOpaque = true
        }
    }
    
}

extension OnboardingPhase3ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDTO.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableDTO[indexPath.row]{
        case .titleCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "OnboardingPhase3TitleCell") as? OnboardingPhase3TitleCell {
                cell.selectionStyle = .none
                return cell
            }
        case .adressCell:
            if let cell = ui_tableview.dequeueReusableCell(withIdentifier: "OnboardingPhase3MapCell") as? OnboardingPhase3MapCell {
                cell.selectionStyle = .none
                cell.configure(adress: self.location_googlePlace_new?.formattedAddress)
                return cell
            }
        case .userTypeCell(choice: let choice, isSelected: let isSelected, let subtitle):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "fullSizeCell", for: indexPath) as? EnhancedFullSizeCell else {
                return UITableViewCell()
            }
            
            cell.configure(choice: choice, isSelected: isSelected)
            cell.configureAComment(title: choice.title, comment: subtitle)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("eho clicked")
        switch tableDTO[indexPath.row]{
        case .titleCell:
            break
        case .userTypeCell(let choice, let isSelected, let subtitle):
            switch choice.id {
            case "entour":
                self.isEntour = !self.isEntour
                self.isBeEntour = false
                self.isBoth = false
                break
            case "been_entour":
                self.isEntour = false
                self.isBeEntour = !self.isBeEntour
                self.isBoth = false
                break
            case "both":
                self.isBoth = !self.isBoth
                self.isEntour = self.isBoth
                self.isBeEntour = self.isBoth
                break
            default:
                break
            }
            self.updateUserType()
            self.loadDTO()
        case .adressCell:
            let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
                vc.placeVCDelegate = self
                self.present(vc, animated: true)
            }
            break
        }
    }
}

extension OnboardingPhase3ViewController:OnboardingEndCellDelegate {
    func showSelectLocation() {
        let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    func updateEntour(isEntour:Bool, isBeEntour:Bool,isAsso:Bool) {
        self.isEntour = isEntour
        self.isBeEntour = isBeEntour
        self.isAsso = isAsso
        if(isBoth == true){
            self.isEntour = true
            self.isBeEntour = true
        }
        EnhancedOnboardingConfiguration.shared.shouldNotDisplayCampain = true
        if(isBeEntour){
            EnhancedOnboardingConfiguration.shared.preference = "contribution"
        }
        var userType = UserType.none
        if isBeEntour {
            userType = .alone
        }
        else if isEntour {
            userType = .neighbour
        }
        
        if(isBoth){
            userType = .both
        }
       
        if isAsso {
            userType = .assos
        }
        if let fromAppDelegate{
            fromAppDelegate.updatePreference(userType: userType)
        }else{
            pageDelegate?.addInfos(userType: userType)

        }
        if (isBeEntour || isAsso || isEntour) && location_name_new != nil {
            self.ui_next_btn.isOpaque = true
        }
    }
}

//MARK: - PlaceViewControllerDelegate -
extension OnboardingPhase3ViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.location_name_new = currentLocationName
        self.location_new = currentlocation
        self.location_googlePlace_new = googlePlace
        if let fromAppDelegate{
            fromAppDelegate.updateLoc(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
             DispatchQueue.main.async {
                 self.loadDTO()
             }
        }else{
            pageDelegate?.addPlace(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
             DispatchQueue.main.async {
                 self.loadDTO()
             }
        }
        if (isBeEntour || isAsso || isEntour) && location_new != nil {
            self.ui_next_btn.isOpaque = true
        }
    }
}

enum UserType:Int {
    case neighbour = 1
    case alone = 2
    case assos = 3
    case both = 4
    case none = 0
    
    func getGoalString() -> String {
        switch self {
        case .alone:
            return "ask_for_help"
        case .neighbour:
            return "offer_help"
        case .assos:
            return "organization"
        case .both:
            return "offer_and_ask_help"
        case .none:
            return ""

        }
    }
}
