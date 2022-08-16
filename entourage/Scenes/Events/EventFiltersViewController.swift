//
//  EventFiltersViewController.swift
//  entourage
//
//  Created by Jerome on 18/07/2022.
//

import UIKit
import GooglePlaces

class EventFiltersViewController: UIViewController {
    
    let minRadius:Float = 1
    let maxRadius:Float = 100
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_info_search: UILabel!
    @IBOutlet weak var ui_slider: MJCustomSlider!
    @IBOutlet weak var ui_min_km: UILabel!
    @IBOutlet weak var ui_max_km: UILabel!
    @IBOutlet weak var ui_label_km_selected: UILabel!
    @IBOutlet weak var ui_constraint_label_km_selected: NSLayoutConstraint!
    @IBOutlet weak var ui_radius_title: UILabel!
    
    @IBOutlet var ui_titles: [UILabel]!
    @IBOutlet var ui_button_images: [UIImageView]!
    
    @IBOutlet weak var ui_address_profile: UILabel!
    @IBOutlet weak var ui_view_profile: UIView!
    @IBOutlet weak var ui_view_google: UIView!
    @IBOutlet weak var ui_view_gps: UIView!
    @IBOutlet weak var ui_bt_google: UIButton!
    
    @IBOutlet weak var ui_bt_validate: UIButton!
    @IBOutlet weak var ui_address_gps: UILabel!
    
    private var selectedItem = 1
    
    var currentFilter = EventActionLocationFilters()
    
    var currentRadius = 0
    
    var googleplaceVC:GMSAutoCompleteVC? = nil
    var selectedPlace:GMSPlace? = nil
    
    weak var delegate:EventFiltersDelegate? = nil
    
    var isFromSettings = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.1))
        ui_error_view.changeTitleAndImage(title: "event_filter_error_place".localized)
        ui_error_view.hide()
        
        ui_bt_validate.setTitle("validate".localized, for: .normal)
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        
        
        ui_min_km.text = "\(Int(minRadius)) km"
        ui_max_km.text = "\(Int(maxRadius)) km"
        ui_radius_title.text = "event_filter_radius_radius".localized
        ui_info_search.text = "event_filter_search".localized
        
        ui_info_search.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_radius_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_min_km.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13, color: .black))
        ui_max_km.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13, color: .black))
        
        ui_titles[0].text = "event_filter_profile".localized
        ui_titles[1].text = "event_filter_google".localized
        ui_titles[2].text = "event_filter_gps".localized
        
        ui_top_view.populateView(title: "event_filter_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self)
        
        currentRadius = currentFilter.radius
        currentRadius = currentRadius > Int(maxRadius) ? Int(maxRadius) : currentRadius
        currentRadius = currentRadius < Int(minRadius) ? Int(minRadius) : currentRadius
        
        ui_slider.setupSlider(delegate: self, imageThumb: UIImage.init(named: "thumb_orange"), minValue: minRadius, maxValue: maxRadius)
        ui_slider.value = Float(currentRadius)
        
        
        switch currentFilter.filterType {
        case .profile:
            selectedItem = 1
        case .google:
            selectedItem = 2
        case .gps:
            selectedItem = 3
        }
        
        changeSelection(isFromStart: true)
        
        setupGooglePlaceViewController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePosition), name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil)
        //Notifs for Gps location activation + retry
        NotificationCenter.default.addObserver(self, selector: #selector(setShowSettings), name: NSNotification.Name(rawValue: kNotificationLocationManagerShowSettings), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelLocation), name: NSNotification.Name(rawValue: kNotificationLocationManagerRefuseShowSettings), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                                   name: UIApplication.willEnterForegroundNotification,
                                                   object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - From notif -
    @objc func updatePosition(notification: NSNotification) {
        if let _arrayLoc = notification.userInfo?[kNotificationLocationUpdatedInfoKey] as? [CLLocation], _arrayLoc.count > 0 {
            let location = _arrayLoc[0]
            let eventLocation = EventLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            location.geocode(completion: { [weak self] (placemark, error) in
                DispatchQueue.main.async {
                    if error == nil, let _placemark = placemark?.first {
                        var _address = ""
                        if let _zipCode = _placemark.postalCode {
                            _address = _zipCode
                        }
                        if let _city = _placemark.locality {
                            _address = "\(_address) \(_city)"
                        }
                        
                        self?.ui_address_gps?.text = _address
                        self?.currentFilter.modifyFilter(name: _address,shortname: _address, eventLocation: eventLocation, radius_distance: self?.currentRadius ?? 0, type: .gps)
                    }
                    else {
                        self?.ui_address_gps?.text = "profileEditLocationPlaceholder".localized
                        self?.currentFilter.modifyFilter(name: "-",shortname: "-", eventLocation: eventLocation, radius_distance: self?.currentRadius ?? 0, type: .gps)
                    }
                }
            })
            LocationManger.sharedInstance.stopUpdate()
        }
        else {
            if !LocationManger.sharedInstance.isAuthorized() {
                LocationManger.sharedInstance.showGeolocationNotAllowedMessage(presenterVC: self)
            }
        }
    }
    @objc func setShowSettings() {
        self.isFromSettings = true
    }
    
    @objc func willEnterForeground() {
        if isFromSettings && selectedItem == 3 {
            isFromSettings = false
            LocationManger.sharedInstance.startLocationUpdate()
        }
    }
    
    @objc func cancelLocation() {
        let _bt = UIButton()
        _bt.tag = 1
        self.action_select(_bt)
    }
    
    //MARK: - IBAction -
    @IBAction func action_validate(_ sender: Any) {
        if currentFilter.validate() {
            delegate?.updateFilters(currentFilter)
            self.goBack()
        }
        else {
            ui_error_view.show()
        }
    }
    
    @IBAction func action_show_google(_ sender: Any) {
        if let _vc = googleplaceVC {
            self.present(_vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func action_select(_ sender: UIButton) {
        var _type = EventActionLocationFilters.EventFilterType.profile
        switch sender.tag {
        case 1:
            _type = EventActionLocationFilters.EventFilterType.profile
        case 2:
            _type = EventActionLocationFilters.EventFilterType.google
        case 3:
            _type = EventActionLocationFilters.EventFilterType.gps
        default:
            break
        }
        if selectedItem == sender.tag { return }
        
        selectedItem = sender.tag
        
        currentFilter.modifyFilter(name: nil,shortname: nil, eventLocation: nil, radius_distance: currentRadius, type: _type)
        
        changeSelection()
    }
    
    //MARK: - Methods -
    func setupGooglePlaceViewController() {
        let filterType: GMSPlacesAutocompleteTypeFilter = GMSPlacesAutocompleteTypeFilter.geocode
        
        self.googleplaceVC = GMSAutoCompleteVC()
        self.googleplaceVC?.setup(filterType: filterType)
        self.googleplaceVC?.delegate = self
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.formattedAddress.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.addressComponents.rawValue))
        self.googleplaceVC?.placeFields = fields
    }
    
    private func changeSelection(isFromStart:Bool = false) {
        var i = 1
        for title in ui_titles {
            if i == selectedItem {
                title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
            }
            else {
                title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            }
            
            i = i + 1
        }
        
        i = 1
        for button in ui_button_images {
            if i == selectedItem {
                button.image = UIImage.init(named: "ic_selector_on")
            }
            else {
                button.image = UIImage.init(named: "ic_selector_off")
            }
            i = i + 1
        }
        
        showHideView(isFromStart:isFromStart)
    }
    
    func showHideView(isFromStart:Bool = false) {
        switch selectedItem {
        case 1:
            ui_view_profile.isHidden = false
            ui_view_google.isHidden = true
            ui_view_gps.isHidden = true
        case 2:
            ui_view_profile.isHidden = true
            ui_view_google.isHidden = false
            ui_view_gps.isHidden = true
        case 3:
            ui_view_profile.isHidden = true
            ui_view_google.isHidden = true
            ui_view_gps.isHidden = false
        default:
            break
        }
        
        populateViews(isFromStart:isFromStart)
    }
    
    func populateViews(isFromStart:Bool = false) {
        switch selectedItem {
        case 1:
            let address = UserDefaults.currentUser?.addressPrimary
            ui_address_profile.text = address?.displayAddress //TODO: mod profile address
            let eventLoc = EventLocation(latitude: address?.latitude, longitude: address?.longitude)
            currentFilter.modifyFilter(name: address?.displayAddress,shortname: address?.displayAddress, eventLocation: eventLoc, radius_distance: currentRadius, type: .profile)
        case 2:
            if isFromStart {
                ui_bt_google.setTitle(currentFilter.addressName, for: .normal)
            }
            else {
                ui_bt_google.setTitle("event_filter_google_placeholder".localized, for: .normal)
            }
        case 3:
            if isFromStart {
                ui_address_gps.text = currentFilter.addressName
            }
            else {
                ui_address_gps.text = "event_filter_position_placeholder".localized
                if LocationManger.sharedInstance.isAuthorized() {
                    LocationManger.sharedInstance.startLocationUpdate()
                }
                else {
                    LocationManger.sharedInstance.showGeolocationNotAllowedMessage(presenterVC: self)
                }
            }
        default:
            break
        }
    }
}

//MARK: - MJCustomSliderDelegate -
extension EventFiltersViewController: MJCustomSliderDelegate {
    func updateLabel() {
        let pos = ui_slider.getPercentScreenPosition()
        ui_constraint_label_km_selected.constant = pos - (ui_label_km_selected.intrinsicContentSize.width / 2)
        ui_label_km_selected.text = "\(Int(ui_slider.value)) km"
        
        currentRadius = Int(ui_slider.value)
        currentFilter.modifyRadius(currentRadius)
    }
}

//MARK: - MJNavBackViewDelegate -
extension EventFiltersViewController: MJNavBackViewDelegate {
    func goBack() {
        self.dismiss(animated: true)
    }
}

//MARK: - GMSAutocompleteViewControllerDelegate -
extension EventFiltersViewController:GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.selectedPlace = place
        self.updateButtonAddressInfos()
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // self.selectedPlace = nil
        self.updateButtonAddressInfos()
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateButtonAddressInfos() {
        if let _address = selectedPlace?.formattedAddress, let comps = selectedPlace?.addressComponents {
            var postCode = ""
            var city = ""
            for gms in comps {
                if gms.types.contains(kGMSPlaceTypePostalCode) {
                    postCode = gms.name
                }
                if gms.types.contains(kGMSPlaceTypeLocality) {
                    city = gms.name
                }
            }
            
            let shortAddress = "\(postCode) \(city)"
            ui_bt_google?.setTitle(_address, for: .normal)
            let eventLocation = EventLocation(latitude: selectedPlace?.coordinate.latitude, longitude: selectedPlace?.coordinate.longitude)
            currentFilter.modifyFilter(name: _address,shortname: shortAddress, eventLocation: eventLocation, radius_distance: currentRadius, type: .google)
        }
        else {
            self.ui_bt_google?.setTitle("profileEditLocationPlaceholder".localized, for: .normal)
        }
    }
}

//MARK: - Protocol Event Filter
protocol EventFiltersDelegate:AnyObject {
    func updateFilters(_ filters:EventActionLocationFilters)
}
