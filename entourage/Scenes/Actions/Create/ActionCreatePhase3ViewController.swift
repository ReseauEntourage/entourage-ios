//
//  ActionCreatePhase3ViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit
import CoreLocation
import GooglePlaces

class ActionCreatePhase3ViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    weak var pageDelegate:ActionCreateMainDelegate? = nil
    
    var location_new:CLLocationCoordinate2D? = nil
    var location_name_new:String? = nil
    var location_googlePlace_new:GMSPlace? = nil
    
    var isFromPlaceSelection = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50
    }
}

//MARK: - Tableview Datasource/delegate -
extension ActionCreatePhase3ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        let _title = String.init(format: "actionCellLocationTitle".localized, pageDelegate?.isContribution() ?? false ? "action_contrib".localized : "action_solicitation".localized)
        
        cell.populateCell(delegate: self, showError: showError, cityName:cityName, title: _title,description: "actionCellLocationDescription".localized)
        
        return cell
    }
}

extension ActionCreatePhase3ViewController:NeighborhoodCreateLocationCellDelegate {
    func showSelectLocation() {
        let sb = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            vc.isFromActions = true
            vc.isContrib = pageDelegate?.isContribution() ?? false
            self.present(vc, animated: true)
        }
    }
}

//MARK: - PlaceViewControllerDelegate -
extension ActionCreatePhase3ViewController: PlaceViewControllerDelegate {
    func modifyPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.location_name_new = currentLocationName
        self.location_new = currentlocation
        self.location_googlePlace_new = googlePlace
        
        pageDelegate?.addPlace(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
        DispatchQueue.main.async {
            self.isFromPlaceSelection = true
            self.ui_tableview.reloadData()
        }
    }
}
