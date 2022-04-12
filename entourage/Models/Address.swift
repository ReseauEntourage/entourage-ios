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
    var location:CLLocation? = nil
    
    enum CodingKeys: String, CodingKey {
        case displayAddress = "display_address"
    }
}
