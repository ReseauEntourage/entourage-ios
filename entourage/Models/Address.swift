//
//  Address.swift
//  entourage
//
//  Created by Jerome on 08/04/2022.
//

import Foundation
import CoreLocation

//MARK: - UserAddress -
struct Address:Codable {
    var displayAddress:String? = nil
    var location:CLLocation? {
        get {
            guard let _lat = latitude, let _long = longitude else {
                return nil
            }
            return CLLocation(latitude: _lat, longitude: _long)
        }
    }
    var google_place_id:String? = nil
    
    
    var latitude:Double? = nil
    var longitude:Double? = nil
   
    init(displayAddress:String? = nil, latitude: Double? = nil, longitude:Double? = nil, google_place_id:String? = nil) {
        self.displayAddress = displayAddress
        self.latitude = latitude
        self.longitude = longitude
        self.google_place_id = google_place_id
    }
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
        case latitude
        case longitude
    }
}
