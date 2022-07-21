//
//  ParamsChoosePlaceViewController.swift
//  entourage
//
//  Created by Jerome on 21/03/2022.
//

import UIKit
import IHProgressHUD
import GooglePlaces

class ParamsChoosePlaceViewController: BasePopViewController {
    
    @IBOutlet weak var ui_constraint_add_place_top: NSLayoutConstraint!
    @IBOutlet weak var ui_view_error: MJErrorInputView!
    @IBOutlet weak var ui_bt_address: UIButton!
    
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    @IBOutlet weak var ui_title_add_place: UILabel!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    var googleplaceVC:GMSAutoCompleteVC? = nil
    var selectedPlace:GMSPlace? = nil
    var currentLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    
    weak var placeVCDelegate:PlaceViewControllerDelegate? = nil
    
    var isFromEvent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsLoggerManager.logEvent(name: View_NewGroup_AddLocation_Screen)
        //Fix height for iPhone 5s / SE first Gen
        if UIDevice.current.deviceTypeScreen == .small {
            ui_constraint_add_place_top.constant = 40
        }
        
        //                OTLogger.logEvent(View_Profile_Action_Zone)//TODO:  Analytics
        ui_top_view.populateView(title: "profileEditLocationTitle".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self, isClose: true)
               
        if isFromEvent {
            ui_label_info.isHidden = true
            ui_title_add_place.text = "profileEditLocationLegend_".localized
        }
        else {
            ui_title_add_place.text = "profileEditLocationLegend*".localized
        }
        
        ui_label_description.text =  "profileEditLocationDescription".localized
        ui_bt_address?.setTitle("profileEditLocationPlaceholder".localized, for: .normal)
        ui_label_info.text = "profileEditLocationLegend".localized
        
        ui_label_description.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_label_description.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        
        ui_title_add_place.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        ui_title_add_place.textColor = .appOrange
        
        ui_label_info.font = ApplicationTheme.getFontLight13Orange().font
        ui_label_info.textColor = ApplicationTheme.getFontLight13Orange().color
        
        ui_bt_address.titleLabel?.font = ApplicationTheme.getFontCourantRegularNoir().font
        ui_bt_address.titleLabel?.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        
        
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setTitle("validate".localized, for: .normal)
        ui_bt_validate.titleLabel?.font = ApplicationTheme.getFontCourantRegularNoir(size: 18).font
        ui_bt_validate.titleLabel?.textColor = ApplicationTheme.getFontCourantRegularNoir().color
        
        ui_view_error.hide()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition), name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil)
        setupGooglePlaceViewController()
    }
    
    private func validateAddress() {
        if let _ = selectedPlace {
            //                OTLogger.logEvent(Action_Profile_Action_Zone_Submit)//TODO:  Analytics
            self.placeVCDelegate?.modifyPlace(currentlocation: nil, currentLocationName: nil, googlePlace: selectedPlace)
            
            self.dismiss(animated: true)
        }
        else if let _ = self.currentLocation {
            //                OTLogger.logEvent(Action_Profile_Action_Zone_Submit)//TODO:  Analytics
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            
            self.placeVCDelegate?.modifyPlace(currentlocation: self.currentLocation?.coordinate, currentLocationName: addressName, googlePlace: nil )
            
            self.dismiss(animated: true)
        }
        else {
            ui_view_error.populateView(title: "profileEditLocationErrorAddress".localized)
            ui_view_error.show()
        }
    }
    
    deinit {
        LocationManger.sharedInstance.stopUpdate()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods -
    func setupGooglePlaceViewController() {
        let filterType: GMSPlacesAutocompleteTypeFilter = GMSPlacesAutocompleteTypeFilter.geocode
        
        self.googleplaceVC = GMSAutoCompleteVC()
        self.googleplaceVC?.setup(filterType: filterType)
        self.googleplaceVC?.delegate = self
    }
    
    @objc func updatePosition(notification: NSNotification) {
        if let _arrayLoc = notification.userInfo?[kNotificationLocationUpdatedInfoKey] as? [CLLocation], _arrayLoc.count > 0 {
            
            self.currentLocation = _arrayLoc[0]
            self.selectedPlace = nil
            
            self.updateButtonAddressInfos()
            LocationManger.sharedInstance.stopUpdate()
        }
    }
    
    func updateButtonAddressInfos() {
        if let _address = selectedPlace?.formattedAddress {
            ui_bt_address?.setTitle(_address, for: .normal)
        }
        else if currentLocation != nil {
            self.currentLocation?.geocode(completion: { [weak self] (placemark, error) in
                
                if error == nil, let _placemark = placemark?.first {
                    DispatchQueue.main.async {
                        var _address = ""
                        
                        if let _zipCode = _placemark.postalCode {
                            _address = _zipCode
                        }
                        if let _city = _placemark.locality {
                            _address = "\(_address) \(_city)"
                        }
                        self?.temporaryAddressName = _address
                        self?.ui_bt_address?.setTitle(_address, for: .normal)
                    }
                }
                else {
                    self?.ui_bt_address?.setTitle("profileEditLocationPlaceholder".localized, for: .normal)
                }
            })
        }
        else {
            self.ui_bt_address?.setTitle("profileEditLocationPlaceholder".localized, for: .normal)
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_location(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation_Geoloc)
        LocationManger.sharedInstance.startLocationUpdate()
        //                OTLogger.logEvent(Action_Profile_SetAction_Zone_Geoloc)//TODO:  Analytics
    }
    
    @IBAction func action_google_place(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation_City)
        if let _vc = googleplaceVC {
            //                    OTLogger.logEvent(Action_Profile_SetAction_Zone_Search)//TODO:  Analytics
            
            self.present(_vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func action_validate(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation_Validate)
        validateAddress()
    }
}

//MARK: - GMSAutocompleteViewControllerDelegate -
extension ParamsChoosePlaceViewController:GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.selectedPlace = place
        self.currentLocation = nil
        self.updateButtonAddressInfos()
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.selectedPlace = nil
        self.currentLocation = nil
        self.updateButtonAddressInfos()
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - MJNavBackViewDelegate -
extension ParamsChoosePlaceViewController: MJNavBackViewDelegate {
    func goBack() {
        AnalyticsLoggerManager.logEvent(name: Action_NewGroup_AddLocation_Close)
        self.dismiss(animated: true)
    }
}

//MARK: - Protocol PlaceViewControllerDelegate -
protocol PlaceViewControllerDelegate: AnyObject {
    func modifyPlace(currentlocation:CLLocationCoordinate2D?, currentLocationName:String?, googlePlace:GMSPlace?)
}
