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
    var isAsso = false
    
    var userTypeSelected = UserType.none
    
    override func viewDidLoad() {
        self.ui_next_btn.isOpaque = true
        self.ui_next_btn.addTarget(self, action: #selector(onNextClick), for: .touchUpInside)
    }
    
    @objc func onNextClick(){
        self.dismiss(animated: false) {
            self.fromAppDelegate?.sendOnboardingEnd()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.ui_next_btn.isOpaque = true
        
    }
    
}

extension OnboardingPhase3ViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OnboardingEndCell
        
        
         var cityName:String? = nil
        
        if let _cityName = self.location_name_new {
            cityName = _cityName
        }
        else if let _gplace = self.location_googlePlace_new?.formattedAddress { //TODO: quel formattage d'adresse ?
            cityName = _gplace
        }

        cell.populateCell(delegate: self, isEntour: isEntour, isBeentour: isBeEntour, addressName: cityName, isAsso: isAsso)
        
        return cell
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
             }
        }else{
            pageDelegate?.addPlace(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
             DispatchQueue.main.async {
                 self.ui_tableview.reloadData()
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
    case none = 0
    
    func getGoalString() -> String {
        switch self {
        case .alone:
            return "ask_for_help"
        case .neighbour:
            return "offer_help"
        case .assos:
            return "organization"
        case .none:
            return ""
        }
    }
}
