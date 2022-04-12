//
//  NeighborhoodCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 06/04/2022.
//

import UIKit
import CoreLocation
import GooglePlaces

class NeighborhoodCreatePhase1ViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var location_new:CLLocationCoordinate2D? = nil
    var location_name_new:String? = nil
    var location_googlePlace_new:GMSPlace? = nil
    
    var isFromPlaceSelection = false
    weak var pageDelegate:NeighborhoodCreateMainDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        ui_tableview.contentInset = contentInsets
        ui_tableview.scrollIndicatorInsets = contentInsets
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
            cell.populateCell(delegate: self )
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellGroupDescription", for: indexPath) as! NeighborhoodCreateDescriptionCell
            cell.populateCell(delegate: self)
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
    func updateFromTextView(text: String?) {
        pageDelegate?.addGroupDescription(text)
    }
    
    func showSelectLocation() {
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    func updateFromTextfield(text: String?) {
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