//
//  OTLoginPlaceViewController.swift
//  entourage
//
//  Created by Jr on 15/07/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTLoginPlaceViewController: UIViewController {
    
    weak var delegate:LoginDelegate? = nil
    
    @IBOutlet weak var ui_constraint_title_top: NSLayoutConstraint!
    @IBOutlet weak var ui_tf_location: OTCustomTextfield!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    
    
    var googleplaceVC:OTGMSAutoCompleteViewController? = nil
    var selectedPlace:GMSPlace? = nil
    var currentLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OTLogger.logEvent(View_Login_Action_Zone)
        let _title = "onboard_place_title"
        let _description = "onboard_place_description"
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: _title)
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: _description)
        
        ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_place_info"), color: .appBlack30, fontSize: 12)
        
        ui_tf_location.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_place_placeholder")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition), name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil)
        setupGooglePlaceViewController()
        
        delegate?.updateButtonNext(isValid: false)
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
            self.delegate?.updateNewAddress(googlePlace: nil, gpsLocation: self.currentLocation,addressName: temporaryAddressName)
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
        OTLogger.logEvent(Action_Login_SetAction_Zone_Geoloc)
    }
}

//MARK: - UITextfieldDelegate -
extension OTLoginPlaceViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let _vc = googleplaceVC {
            OTLogger.logEvent(Action_Login_SetAction_Zone_Search)
            
            self.present(_vc, animated: true, completion: nil)
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTLoginPlaceViewController:OTGMSAutoCompleteViewControllerProtocol {
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
