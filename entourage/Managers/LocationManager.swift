//
//  LocationManager.swift
//  entourage
//
//  Created by Jerome on 19/01/2022.
//

import CoreLocation

let kNotificationLocationUpdated = "NotificationLocationUpdated"
let kNotificationLocationUpdatedInfoKey = "NotificationLocationUpdatedInfoKey"

let kNotificationLocationAuthorizationChanged = "NotificationLocationAuthorizationChanged"
let kNotificationLocationAuthorizationChangedKey = "NotificationLocationAuthorizationChangedKey"

let kNotificationLocationManagerShowSettings = "kNotifLocationShowSettings"
let kNotificationLocationManagerRefuseShowSettings = "kNotifLocationRefuseShowSettings"

class LocationManger:NSObject {
    private var locationManager:CLLocationManager!
    
    private var status:CLAuthorizationStatus?
    
    static let sharedInstance = LocationManger()
    
    private override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.delegate = self
        self.locationManager.activityType = .other
        self.locationManager.distanceFilter = 10
        
        updateStatus(manager: locationManager)
    }
    
    deinit {
        locationManager.stopUpdatingLocation()
        locationManager = nil
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus? {
        return status
    }
    
    func startLocationUpdate() {
        getAuthorizationLocation()
        startUpdate()
    }
    
    private func updateStatus(manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
    }
    
    func getAuthorizationLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return locationManager?.location
    }
    
    private func startUpdate() {
        stopUpdate()
        locationManager.startUpdatingLocation()
        updateStatus(manager: locationManager)
    }
    
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    
    func showGeolocationNotAllowedMessage(message:String? = nil, presenterVC:UIViewController? = nil) {
        
        let rootVC = presenterVC != nil ? presenterVC : AppState.getTopViewController()
        let message = message != nil ? message : "authGpsSettings".localized
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "refuseAlert".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "toSettings".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "errorSettings".localized, message: message, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        alertVC.delegate = self
        alertVC.show()
    }
    
    func showGeolocationNotFound(message:String) {
        let rootVC = AppState.getTopViewController()
        let alertVC = UIAlertController(title: "tryAgain".localized, message: message, preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        
        alertVC.addAction(actionOk)
        
        if let navVc = rootVC as? UINavigationController {
            let topVc = navVc.topViewController
            if let _topVC = topVc?.presentedViewController {
                _topVC.present(alertVC, animated: true, completion: nil)
                return
            }
        }
        rootVC?.present(alertVC, animated: true, completion: nil)
    }
    
    func isAuthorized() -> Bool {
       return (LocationManger.sharedInstance.getAuthorizationStatus() == .authorizedAlways || LocationManger.sharedInstance.getAuthorizationStatus() == .authorizedWhenInUse)
    }
}

//MARK: - MJAlertControllerDelegate -
extension LocationManger: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        let notif = Notification(name: NSNotification.Name(rawValue: kNotificationLocationManagerRefuseShowSettings), object: nil,userInfo: nil)
        NotificationCenter.default.post(notif)
    }
    func validateRightButton(alertTag: MJAlertTAG) {
        if self.status == .denied {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                let notif = Notification(name: NSNotification.Name(rawValue: kNotificationLocationManagerShowSettings), object: nil,userInfo: nil)
                NotificationCenter.default.post(notif)
                UIApplication.shared.open(url, options: [:],completionHandler:nil)
            }
        }
        else {
            self.startLocationUpdate()
        }
    }
}

extension LocationManger:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]) {
        let infos = [kNotificationLocationUpdatedInfoKey: locations]
        let notif = Notification(name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil,userInfo: infos)
        NotificationCenter.default.post(notif)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.print("***** loc manager delegate : did fail error : \(error.localizedDescription) ")
        // Handle failure to get a user’s location
        let notif = Notification(name: NSNotification.Name(rawValue: kNotificationLocationUpdated), object: nil,userInfo: nil)
        NotificationCenter.default.post(notif)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateStatus(manager:manager)
    }
}
