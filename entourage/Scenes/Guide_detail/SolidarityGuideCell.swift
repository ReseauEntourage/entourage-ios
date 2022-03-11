//
//  SolidarityGuideCell.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import UIKit
import CoreLocation

class SolidarityGuideCell: UITableViewCell {

    let identifier = "guideCell"
    
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var addressLabel:UILabel!
    @IBOutlet weak var distanceLabel:UILabel!
    @IBOutlet weak var btnAppeler:UIButton?
    
    var poiItem:MapPoi?
    
    func configure(poi:MapPoi) {
        self.poiItem = poi
        self.titleLabel.text = poi.name
        self.addressLabel.text = poi.address
        self.btnAppeler?.isHidden = poi.phone?.count == 0
        self.distanceLabel.text = self.getDistance(poi: poi)
    }

    private func getDistance(poi:MapPoi) -> String {
        let distance = calculateDistanceToPoi(poi: poi)
        return toDistance(distance: distance)
    }
    
    private func calculateDistanceToPoi(poi:MapPoi) -> Double {
        guard let poiLat = poi.latitude, let poiLon = poi.longitude else { return -1 }
        let poiLocation = CLLocation(latitude:poiLat, longitude: poiLon)
        if let currentLocation = LocationManger.sharedInstance.getCurrentLocation() {
            return currentLocation.distance(from: poiLocation)
        }
        return -1
    }
    
    
    //MARK: - vrsion OBJC :
    func toDistance(distance:Double) -> String {
        let distanceAmount = getDistance(distance: distance)
        let distanceQualifier = getDistanceQualifier(distance: distance)
        
        return String.init(format: "%d%@", distanceAmount, distanceQualifier)
    }
    
    func getDistance(distance:Double) -> Int {
        if distance < 1000 {
            return Int(round(distance));
        }
        
        return Int(round(distance / 1000))
    }
    
    func getDistanceQualifier(distance:Double) ->String {
        if distance < 1000 {
            return "m"
        }
        
        return "km"
    }
    @IBAction func action_phone(_ sender: Any) {
        callPhone()
    }
    
    func callPhone() {
//        [OTLogger logEvent:Action_guideMap_CallPOI]; //TODO: a faire analytics
        if let _phone = self.poiItem?.phone {
            var component = URLComponents.init()
            component.path = _phone
            component.scheme = "tel"
            if let _url = component.url {
                UIApplication.shared.open(_url, options: [:], completionHandler: nil)
            }
        }
    }
}
