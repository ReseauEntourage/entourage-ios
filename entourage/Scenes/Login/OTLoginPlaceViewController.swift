//
//  OTLoginPlaceViewController.swift
//  entourage
//
//  Created by Jr on 15/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import GooglePlaces

class OTLoginPlaceViewController: UIViewController {
    
    weak var delegate:LoginDelegate? = nil
    
    @IBOutlet weak var ui_constraint_title_top: NSLayoutConstraint!
    @IBOutlet weak var ui_tf_location: OTCustomTextfield!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    
    
    var googleplaceVC:GMSAutoCompleteVC? = nil
    var selectedPlace:GMSPlace? = nil
    var currentLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        OTLogger.logEvent(View_Login_Action_Zone)
        let _title = "onboard_place_title"
        let _description = "onboard_place_description"
        ui_label_title.text =  _title.localized
        ui_label_description.text =  _description.localized
        
        ui_label_info.attributedText = Utils.formatStringItalicOnly(stringMessage:  "onboard_place_info".localized, color: .appBlack30, fontSize: 12)
        
        ui_tf_location.placeholder =  "onboard_place_placeholder".localized
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition), name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil)
        setupGooglePlaceViewController()
        
        delegate?.updateButtonNext(isValid: false)
    }
    
    deinit {
        LocationManger.sharedInstance.stopUpdate()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Methods -
    func setupGooglePlaceViewController() {
        let filterType: GMSPlacesAutocompleteTypeFilter = GMSPlacesAutocompleteTypeFilter.geocode
        
        self.googleplaceVC = GMSAutoCompleteVC()
        self.googleplaceVC?.setup(filterType:filterType)
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
//        OTLogger.logEvent(Action_Login_SetAction_Zone_Geoloc)
    }
}

//MARK: - UITextfieldDelegate -
extension OTLoginPlaceViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let _vc = googleplaceVC {
//            OTLogger.logEvent(Action_Login_SetAction_Zone_Search)
            
            self.present(_vc, animated: true, completion: nil)
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTLoginPlaceViewController:GMSAutocompleteViewControllerDelegate {
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
