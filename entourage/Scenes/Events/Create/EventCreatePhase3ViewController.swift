//
//  EventCreatePhase1ViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit
import CoreLocation
import GooglePlaces

class EventCreatePhase3ViewController: UIViewController {
    
    weak var pageDelegate:EventCreateMainDelegate? = nil
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var isOnline:Bool? = nil
    var onlineUrl:String? = nil
    var place:EventLocation? = nil
    var placeName:String? = nil
    var location_googlePlace:GMSPlace? = nil
    
    var hasplaceLimit = false
    var nbPlaceLimit = 0
    
    var isFromPlaceSelection = false
    
    var currentEvent:Event? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 50

        if pageDelegate?.isEdit() ?? false {
            currentEvent = pageDelegate?.getCurrentEvent()
        }
    }
}
//MARK: - UITableView datasource / Delegate -
extension EventCreatePhase3ViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPlace", for: indexPath) as! EventPlaceCell
            
            var showError = false
            var cityName:String? = nil
            if isFromPlaceSelection {
                self.isFromPlaceSelection = false
                if let _cityName = self.placeName {
                    cityName = _cityName
                }
                else if let _gplace = self.location_googlePlace?.formattedAddress { //TODO: quel formattage d'adresse ?
                    cityName = _gplace
                }
                showError = cityName == nil
            }
            else {
                cityName = (currentEvent?.addressName != nil && isOnline == nil) ? currentEvent?.addressName : nil
            }
            
            let _isOnline = (currentEvent?.isOnline != nil && isOnline == nil) ? currentEvent!.isOnline! : isOnline ?? false
            let _onlineUrl = (currentEvent?.onlineEventUrl != nil  && isOnline == nil) ? currentEvent!.onlineEventUrl : onlineUrl
        
            cell.populateCell(delegate: self, showError:showError, cityName: cityName, urlOnline: _onlineUrl, isOnline: _isOnline)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLimit", for: indexPath) as! EventPlaceLimitCell
        
        let _hasplaceLimit = currentEvent?.metadata?.hasPlaceLimit != nil ? currentEvent!.metadata!.hasPlaceLimit! : hasplaceLimit
        let _nbplaceLimit = currentEvent?.metadata?.place_limit != nil ? currentEvent!.metadata!.place_limit! : nbPlaceLimit
        
        cell.populateCell(delegate: self,hasPlaceLimit: _hasplaceLimit, limitNb: _nbplaceLimit)
        return cell
    }
}

//MARK: - Delegates -
extension EventCreatePhase3ViewController:PlaceViewControllerDelegate, EventCreateLocationCellDelegate {
    func showSelectLocation() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation)
        let sb = UIStoryboard.init(name: "ProfileParams", bundle: nil)
        
        if let vc = sb.instantiateViewController(withIdentifier: "place_choose_vc") as? ParamsChoosePlaceViewController {
            vc.placeVCDelegate = self
            self.present(vc, animated: true)
        }
    }
    
    func modifyPlace(currentlocation:CLLocationCoordinate2D?, currentLocationName:String?, googlePlace:GMSPlace?) {
        Logger.print("***** modify place : \(currentlocation) -- \(currentLocationName) - Goog \(googlePlace)")
        self.placeName = currentLocationName
        
        self.isFromPlaceSelection = true
        
        if let currentlocation = currentlocation {
            self.place = EventLocation()
            self.place?.latitude = currentlocation.latitude
            self.place?.longitude = currentlocation.longitude
        }
        else {
            self.place = nil
        }
        
        self.location_googlePlace = googlePlace
        pageDelegate?.addOnline(url: nil)
        pageDelegate?.addPlaceType(isOnline: false)
        pageDelegate?.addPlace(currentlocation: currentlocation, currentLocationName: currentLocationName, googlePlace: googlePlace)
        
        DispatchQueue.main.async {
            self.ui_tableview.reloadData()
        }
    }
    
    func resetPlaceOnlineSelection(isOnline:Bool) {
        self.onlineUrl = nil
        self.isOnline = isOnline
        self.placeName = nil
        self.place = nil
        self.location_googlePlace = nil
        pageDelegate?.addPlace(currentlocation: nil, currentLocationName: nil, googlePlace: nil)
        pageDelegate?.addOnline(url: nil)
        pageDelegate?.addPlaceType(isOnline: isOnline)
        self.ui_tableview.reloadData()
    }
    
    func addOnlineUrl(urlOnline:String?) {
        self.onlineUrl = urlOnline
        Logger.print("***** add online url : \(onlineUrl)")
        pageDelegate?.addPlace(currentlocation: nil, currentLocationName: nil, googlePlace: nil)
        pageDelegate?.addOnline(url: urlOnline)
        pageDelegate?.addPlaceType(isOnline: true)
    }
    
    func addPlaceLimit(hasPlaceLimit:Bool, limitNb:Int) {
        self.hasplaceLimit = hasPlaceLimit
        self.nbPlaceLimit = limitNb
        Logger.print("***** add Limit : \(hasPlaceLimit) - \(limitNb)")
        pageDelegate?.addPlaceLimit(hasLimit: hasPlaceLimit,nbPlaces: limitNb)
    }
}
