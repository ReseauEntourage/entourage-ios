//
//  Pedagogic.swift
//  entourage
//
//  Created by Jerome on 09/06/2022.
//

import Foundation


struct PedagogicResources: Codable {
    var title:String = ""
    var resources = [PedagogicResource]()
}

struct PedagogicResource: Codable {
    var id:Int = 0
    var uuid_v2:String = ""
    var title = ""
    private var categoryStr = ""
    var description:String? = nil
    var imageUrl:String? = nil
    var url:String? = nil
    var isRead = false
    var bodyHtml:String? = nil
    var duration:Int? = 0
    
    var tag:PedagogicTag {
        get {
            switch categoryStr {
            case "understand":
                return .Understand
            case "act":
                return .Act
            case "inspire":
                return .Inspire
            default:
                return .None
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid_v2 
        case title = "name"
        case categoryStr = "category"
        case description = "description"
        case imageUrl = "image_url"
        case url
        case isRead = "watched"
        case bodyHtml = "html"
        case duration
    }
}

enum PedagogicTag {
    case All
    case Understand
    case Act
    case Inspire
    case None
}
