//
//  Association.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation

struct Partner:Codable {
    var name:String = ""
    var postalCode:String?
    var userRoleTitle:String?
    var isCreation:Bool? = false
    var aid:Int?
    var smallLogoUrl:String?
    var largeLogoUrl:String?
    var descr:String?
    var phone:String?
    var address:String?
    var websiteUrl:String?
    var email:String?
    var donations_needs:String?
    var volunteers_needs:String?
    var isFollowing:Bool? = false
    
    enum CodingKeys: String, CodingKey {
        case name
        case postalCode = "postal_code"
        case userRoleTitle = "user_role_title"
        case aid = "id"
        case smallLogoUrl = "small_logo_url"
        case largeLogoUrl = "large_logo_url"
        case descr = "description"
        case phone
        case address
        case websiteUrl = "website_url"
        case email
        case donations_needs
        case volunteers_needs
        case isFollowing = "following"
    }
}
