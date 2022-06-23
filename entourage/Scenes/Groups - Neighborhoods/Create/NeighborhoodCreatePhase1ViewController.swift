//
//  NeighborhoodCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 06/04/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IQKeyboardManagerSwift

class NeighborhoodCreatePhase1ViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var location_new:CLLocationCoordinate2D? = nil
    var location_name_new:String? = nil
    var location_googlePlace_new:GMSPlace? = nil
    var group_name:String? = nil
    var group_description:String? = nil
    
    var isFromPlaceSelection = false
    weak var pageDelegate:NeighborhoodCreateMainDelegate? = nil
    
    //Use for growing Textview
    var realViewFrame:CGRect = .zero
    var hasGrowingTV = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
        
        IQKeyboardManager.shared.enable = true
        //Use for growing Textview
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(moveFromGrow), name: Notification.Name(kNotifGrowTextview), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsLoggerManager.logEvent(name: View_NewGroup_Step1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if realViewFrame == .zero {
            realViewFrame = self.view.frame
        }
    }
    
    //Use for growing Textview
    @objc func moveFromGrow(notification: NSNotification) {
        guard let isUp = notification.userInfo?[kNotifGrowTextviewKeyISUP] as? Bool else {return}
        hasGrowingTV = true
        animateViewMoving(isUp, moveValue: 18)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if hasGrowingTV {
            UIView.beginAnimations( "animateView", context: nil)
            self.view.frame.origin.y = 0
            UIView.commitAnimations()
            hasGrowingTV = false
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - UITableView datasource / Delegate -
extension NeighborhoodCreatePhase1ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroupName", for: indexPath) as! NeighborhoodCreateNameCell
            cell.populateCell(delegate: self,name: group_name)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroupDescription", for: indexPath) as! NeighborhoodCreateDescriptionCell
            cell.populateCell(title: "neighborhoodCreateDescriptionTitle", description: "neighborhoodCreateDescriptionSubtitle", placeholder: "neighborhoodCreateTitleDescriptionPlaceholder", delegate: self,about: group_description, textInputType:.descriptionAbout)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroupPlace", for: indexPath) as! NeighborhoodCreateLocationCell
            
            var showError = false
            var cityName:String? = nil
            if isFromPlaceSelection {
                self.isFromPlaceSelection = false
                if let _cityName = self.location_name_new {
                    cityName = _cityName
                }
                else if let _gplace = self.location_googlePlace_new?.formattedAddress { //TODO: quel formattage d'adresse ?
                    cityName = _gplace
                }
                showError = cityName == nil
            }
            cell.populateCell(delegate: self, showError: showError, cityName:cityName)
            
            return cell
        }
    }
}

//MARK: - NeighborhoodCreateDescriptionCellDelegate / NeighborhoodCreateLocationCellDelegate -
extension NeighborhoodCreatePhase1ViewController: NeighborhoodCreateDescriptionCellDelegate, NeighborhoodCreateLocationCellDelegate, NeighborhoodCreateNameCellDelegate {
    func updateFromTextView(text: String?,textInputType:TextInputType) {
        self.group_description = text
        pageDelegate?.addGroupDescription(text)
    }
    
    func showSelectLocation() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation)
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    func updateFromGroupNameTF(text: String?) {
        self.group_name = text
        pageDelegate?.addGroupName(text!)
    }
}

//MARK: - PlaceViewControllerDelegate -
extension NeighborhoodCreatePhase1ViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.location_name_new = currentLocationName
        self.location_new = currentlocation
        self.location_googlePlace_new = googlePlace
        Logger.print("***** return place : \(currentLocationName) - \(googlePlace)")
        pageDelegate?.addGroupPlace(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
        DispatchQueue.main.async {
            self.isFromPlaceSelection = true
            self.ui_tableview.reloadData()
        }
    }
}
