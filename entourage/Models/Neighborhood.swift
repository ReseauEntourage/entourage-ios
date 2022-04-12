//
//  Neighborhood.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation
struct Neighborhood:Codable {
    var uid:Int = 0
    var name:String = ""
    var aboutGroup:String?
    var welcomeMessage:String?
    var photoUrl:String?
    var membersCount:Int = 0
    var latitude:Double = 0
    var longitude:Double = 0
    
    var address:Address? = nil
    
    var interests:[String]? = nil
    var members:[User]? = nil
    
    var aboutEthics:String? = nil
    var past_outings_count:Int = 0
    var future_outings_count:Int = 0
    var has_ongoing_outing = false
    
    var neighborhood_image_id:Int? = nil // Use to pass the image info from the gallery
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case name
        case aboutGroup = "description"
        case welcomeMessage = "welcome_message"
        case membersCount = "members_count"
        case photoUrl = "photo_url"
        case aboutEthics = "ethics"
        
        case address
        
        case interests
        case members
        case past_outings_count
        case future_outings_count
        case has_ongoing_outing
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if name.count > 0 {
            dict["name"] = name
        }
        
        //TODO: avec la nouvelle version du WS de nico
        if address?.displayAddress?.count ?? 0 > 0 {
            dict["place_name"] = address!.displayAddress!
        }
        if address?.location?.coordinate.latitude ?? 0 > 0 {
            dict["latitude"] = address!.location!.coordinate.latitude
        }
        if address?.location?.coordinate.longitude ?? 0 > 0 {
            dict["longitude"] = address!.location!.coordinate.longitude
        }
        
        if !(aboutGroup?.isEmpty ?? true) {
            dict["description"] = aboutGroup!
        }
        
        if !(aboutEthics?.isEmpty ?? true) {
            dict["ethics"] = aboutEthics!
        }
        if !(welcomeMessage?.isEmpty ?? true) {
            dict["welcome_message"] = welcomeMessage!
        }
        
        if let interests = interests, interests.count > 0 {
            dict["interests"] = interests
        }
       
        if !(photoUrl?.isEmpty ?? true) {
            dict["photo_url"] = photoUrl!
        }
        
        if neighborhood_image_id != nil {
            dict["neighborhood_image_id"] = neighborhood_image_id!
        }
        
        
        return dict
    }
}


struct NeighborhoodImage:Codable {
    var uid:Int
    var title:String?
    var imageUrl:String
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case title
        case imageUrl = "image_url"
    }
}
