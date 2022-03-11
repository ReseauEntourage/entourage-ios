//
//  OTOnboardingPlaceViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD
import GooglePlaces

class OTOnboardingPlaceViewController: UIViewController {
    
    @IBOutlet weak var ui_constraint_title_top: NSLayoutConstraint!
    @IBOutlet weak var ui_tf_location: OTCustomTextfield!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    
    weak var delegate:OnboardV2Delegate? = nil
    
    var googleplaceVC:GMSAutoCompleteVC? = nil//OTGMSAutoCompleteViewController? = nil
    var selectedPlace:GMSPlace? = nil
    var currentLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    
    @objc var isFromProfile = false
    
    @objc var isSecondaryAddress = false
    var isSdf = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromProfile {
            if isSecondaryAddress {
//                OTLogger.logEvent(View_Profile_Action_Zone2)//TODO:  Analytics
            }
            else {
//                OTLogger.logEvent(View_Profile_Action_Zone)//TODO:  Analytics
            }
           
           // ui_constraint_title_top.constant = ui_constraint_title_top.constant + 20
            ui_label_title.text =  "defineActionZoneTitle".localized
            
            ui_label_description.text =  "location_information_profile".localized
            ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage:  "onboard_place_info".localized, color: .appBlack30, fontSize: 12)
        }
        else {
            if !isSecondaryAddress {
//                OTLogger.logEvent(View_Onboarding_Action_Zone)//TODO:  Analytics
                let _title = isSdf ? "onboard_place_title_sdf" : "onboard_place_title"
                let _description = isSdf ? "onboard_place_description_sdf" : "onboard_place_description"
                ui_label_title.text =  _title.localized
                ui_label_description.text =  _description.localized
                
                ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage:  "onboard_place_info".localized, color: .appBlack30, fontSize: 12)
                
                ui_tf_location.placeholder =  "onboard_place_placeholder".localized
            }
            else {
//                OTLogger.logEvent(View_Onboarding_Action_Zone2)//TODO:  Analytics
                let _title = isSdf ? "onboard_place_title2_sdf" : "onboard_place_title2"
                let _description = isSdf ? "onboard_place_description2_sdf" : "onboard_place_description2"
                ui_label_title.text =  _title.localized
                ui_label_description.text =  _description.localized
                
                ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage:  "onboard_place_info".localized, color: .appBlack30, fontSize: 12)
                
                ui_tf_location.placeholder =  "onboard_place_placeholder".localized
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition), name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil)
        setupGooglePlaceViewController()
        
        if selectedPlace != nil || currentLocation != nil {
            self.updateTextfieldInfos()
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            if isSecondaryAddress {
                delegate?.updateButtonNext(isValid: true)
            }
            else {
                delegate?.updateButtonNext(isValid: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromProfile {
            addButtonValidate()
        }
    }
    
    func addButtonValidate() {
        let validateButton = UIBarButtonItem.init(title: "Valider", style: .done, target: self, action: #selector(validateAddress))
        self.navigationItem.rightBarButtonItem = validateButton
    }
    
    @objc func validateAddress() {
        sendAddAddress()
    }
    
    func sendAddAddress() {
        if let _place = selectedPlace {
            if isSecondaryAddress {
//                OTLogger.logEvent(Action_Profile_Action_Zone2_Submit)//TODO:  Analytics
            }
            else {
//                OTLogger.logEvent(Action_Profile_Action_Zone_Submit)//TODO:  Analytics
            }
            
            IHProgressHUD.show()
            if let placeId = _place.placeID {
                UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: isSecondaryAddress) { [weak self] error in
                    IHProgressHUD.dismiss()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        else if let _lat = self.currentLocation?.coordinate.latitude, let _long = self.currentLocation?.coordinate.longitude {
            IHProgressHUD.show()
            if isSecondaryAddress {
//                OTLogger.logEvent(Action_Profile_Action_Zone2_Submit)//TODO:  Analytics
            }
            else {
//                OTLogger.logEvent(Action_Profile_Action_Zone_Submit)//TODO:  Analytics
            }
            
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            
            UserService.updateUserAddressWith(name: addressName, latitude: _lat, longitude: _long, isSecondaryAddress: isSecondaryAddress) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.navigationController?.popViewController(animated: true)
            }
        }
        else {
            let alertVC = UIAlertController.init(title:  "invalidAddress".localized, message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title:  "OK".localized, style: .cancel, handler: nil)
            
            alertVC.addAction(action)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    deinit {
        LocationManger.sharedInstance.stopUpdate()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods -
    func setupGooglePlaceViewController() {
        let filterType: GMSPlacesAutocompleteTypeFilter = GMSPlacesAutocompleteTypeFilter.geocode
        
        self.googleplaceVC = GMSAutoCompleteVC()//  OTGMSAutoCompleteViewController()
        self.googleplaceVC?.setup(filterType: filterType)
        self.googleplaceVC?.delegate = self
    }
    
    @objc func updatePosition(notification: NSNotification) {
        if let _arrayLoc = notification.userInfo?[kNotificationLocationUpdatedInfoKey] as? [CLLocation], _arrayLoc.count > 0 {
            
            self.currentLocation = _arrayLoc[0]
            self.selectedPlace = nil
            
            self.updateTextfieldInfos()
            self.delegate?.updateNewAddress(googlePlace: nil, gpsLocation: self.currentLocation,addressName: temporaryAddressName)
            LocationManger.sharedInstance.stopUpdate()
        }
    }
    
    func updateTextfieldInfos() {
        if let _address = selectedPlace?.formattedAddress {
            ui_tf_location.text = _address
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
                        self?.ui_tf_location.text = _address
                    }
                }
            })
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_location(_ sender: Any) {
        LocationManger.sharedInstance.startLocationUpdate()
        if isFromProfile {
            if isSecondaryAddress {
//                OTLogger.logEvent(Action_Profile_SetAction_Zone2_Geoloc)//TODO:  Analytics
            }
            else {
//                OTLogger.logEvent(Action_Profile_SetAction_Zone_Geoloc)//TODO:  Analytics
            }
        }
        else {
            if isSecondaryAddress {
//                 OTLogger.logEvent(Action_Onboarding_SetAction_Zone2_Geoloc)//TODO:  Analytics
            }
            else {
//                 OTLogger.logEvent(Action_Onboarding_SetAction_Zone_Geoloc)//TODO:  Analytics
            }
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPlaceViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let _vc = googleplaceVC {
            if isFromProfile {
                if isSecondaryAddress {
//                    OTLogger.logEvent(Action_Profile_SetAction_Zone2_Search)//TODO:  Analytics
                }
                else {
//                    OTLogger.logEvent(Action_Profile_SetAction_Zone_Search)//TODO:  Analytics
                }
            }
            else {
                if isSecondaryAddress {
//                    OTLogger.logEvent(Action_Onboarding_SetAction_Zone2_Search)//TODO:  Analytics
                }
                else {
//                    OTLogger.logEvent(Action_Onboarding_SetAction_Zone_Search)//TODO:  Analytics
                }
            }
            
            self.present(_vc, animated: true, completion: nil)
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPlaceViewController:GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.selectedPlace = place
        self.currentLocation = nil
        self.updateTextfieldInfos()
        self.dismiss(animated: true, completion: nil)
        self.delegate?.updateNewAddress(googlePlace: self.selectedPlace, gpsLocation: nil,addressName: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.selectedPlace = nil
        self.currentLocation = nil
        self.updateTextfieldInfos()
        self.dismiss(animated: true, completion: nil)
        self.delegate?.updateNewAddress(googlePlace: nil, gpsLocation: nil,addressName: nil)
    }
}
