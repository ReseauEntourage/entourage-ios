//
//  OTOnboardingPlaceViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTOnboardingPlaceViewController: UIViewController {
    
    @IBOutlet weak var ui_constraint_title_top: NSLayoutConstraint!
    @IBOutlet weak var ui_tf_location: OTCustomTextfield!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    
    weak var delegate:OnboardV2Delegate? = nil
    
    var googleplaceVC:OTGMSAutoCompleteViewController? = nil
    var selectedPlace:GMSPlace? = nil
    var currentLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    
    @objc var isFromProfile = false
    
    @objc var isSecondaryAddress = false
    var isSdf = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFromProfile {
            OTLogger.logEvent(View_Profile_Action_Zone)
           // ui_constraint_title_top.constant = ui_constraint_title_top.constant + 20
            ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "defineActionZoneTitle")
            
            ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "location_information_profile")
            ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_place_info"), color: .appBlack30, fontSize: 12)
        }
        else {
            if !isSecondaryAddress {
                OTLogger.logEvent(View_Onboarding_Action_Zone)
                let _title = isSdf ? "onboard_place_title_sdf" : "onboard_place_title"
                let _description = isSdf ? "onboard_place_description_sdf" : "onboard_place_description"
                ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: _title)
                ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: _description)
                
                ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_place_info"), color: .appBlack30, fontSize: 12)
                
                ui_tf_location.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_place_placeholder")
            }
            else {
                OTLogger.logEvent(View_Onboarding_Action_Zone2)
                let _title = isSdf ? "onboard_place_title2_sdf" : "onboard_place_title2"
                let _description = isSdf ? "onboard_place_description2_sdf" : "onboard_place_description2"
                ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: _title)
                ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: _description)
                
                ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_place_info"), color: .appBlack30, fontSize: 12)
                
                ui_tf_location.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_place_placeholder")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition), name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil)
        setupGooglePlaceViewController()
        
        if selectedPlace != nil || currentLocation != nil {
            self.updateTextfieldInfos()
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
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
            OTLogger.logEvent(Action_Profile_Action_Zone_Submit)
            SVProgressHUD.show()
            OTAuthService.updateUserAddress(withPlaceId: _place.placeID, isSecondaryAddress: self.isSecondaryAddress) { (error) in
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        }
        else if let _lat = self.currentLocation?.coordinate.latitude, let _long = self.currentLocation?.coordinate.longitude {
            SVProgressHUD.show()
            OTLogger.logEvent(Action_Profile_Action_Zone_Submit)
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            OTAuthService.updateUserAddress(withName: addressName, andLatitude: NSNumber.init(value: _lat), andLongitude: NSNumber.init(value: _long), isSecondaryAddress: self.isSecondaryAddress) { (error) in
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "invalidAddress"), message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "OK"), style: .cancel, handler: nil)
            
            alertVC.addAction(action)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    deinit {
        OTLocationManager.sharedInstance()?.stopLocationUpdates()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods -
    func setupGooglePlaceViewController() {
        let filterType: GMSPlacesAutocompleteTypeFilter = GMSPlacesAutocompleteTypeFilter.geocode
        
        self.googleplaceVC = OTGMSAutoCompleteViewController()
        self.googleplaceVC?.setup(filterType)
        self.googleplaceVC?.delegate = self
    }
    
    @objc func updatePosition(notification: NSNotification) {
        if let _arrayLoc = notification.userInfo?[kNotificationLocationUpdatedInfoKey] as? [CLLocation], _arrayLoc.count > 0 {
            
            self.currentLocation = _arrayLoc[0]
            self.selectedPlace = nil
            
            self.updateTextfieldInfos()
            self.delegate?.updateNewAddress(googlePlace: nil, gpsLocation: self.currentLocation,addressName: temporaryAddressName,is2ndAddress: isSecondaryAddress)
            OTLocationManager.sharedInstance()?.stopLocationUpdates()
        }
    }
    
    func updateTextfieldInfos() {
        if let _address = selectedPlace?.formattedAddress {
            ui_tf_location.text = _address
        }
        else if currentLocation != nil {
            self.currentLocation?.geocode(completion: { (placemark, error) in
                
                if error == nil, let _placemark = placemark?.first {
                    DispatchQueue.main.async {
                        var _address = ""
                        
                        if let _zipCode = _placemark.postalCode {
                            _address = _zipCode
                        }
                        if let _city = _placemark.locality {
                            _address = "\(_address) \(_city)"
                        }
                        self.temporaryAddressName = _address
                        self.ui_tf_location.text = _address
                    }
                }
            })
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_location(_ sender: Any) {
        OTLocationManager.sharedInstance()?.startLocationUpdates()
        if isFromProfile {
            OTLogger.logEvent(Action_Profile_SetAction_Zone_Geoloc)
        }
        else {
            if isSecondaryAddress {
                 OTLogger.logEvent(Action_Onboarding_SetAction_Zone2_Geoloc)
            }
            else {
                 OTLogger.logEvent(Action_Onboarding_SetAction_Zone_Geoloc)
            }
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPlaceViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let _vc = googleplaceVC {
            if isFromProfile {
                OTLogger.logEvent(Action_Profile_SetAction_Zone_Search)
            }
            else {
                if isSecondaryAddress {
                    OTLogger.logEvent(Action_Onboarding_SetAction_Zone2_Search)
                }
                else {
                    OTLogger.logEvent(Action_Onboarding_SetAction_Zone_Search)
                }
            }
            
            self.present(_vc, animated: true, completion: nil)
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPlaceViewController:OTGMSAutoCompleteViewControllerProtocol {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        self.selectedPlace = place
        self.currentLocation = nil
        self.updateTextfieldInfos()
        self.dismiss(animated: true, completion: nil)
        self.delegate?.updateNewAddress(googlePlace: self.selectedPlace, gpsLocation: nil,addressName: nil,is2ndAddress: isSecondaryAddress)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.selectedPlace = nil
        self.currentLocation = nil
        self.updateTextfieldInfos()
        self.dismiss(animated: true, completion: nil)
        self.delegate?.updateNewAddress(googlePlace: nil, gpsLocation: nil,addressName: nil,is2ndAddress: isSecondaryAddress)
    }
}
