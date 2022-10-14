//
//  MapPoi.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import Foundation
import UIKit

struct MapPoi : Codable {
    var partnerId:Int? = 0
    var address:String? = nil
    var phone:String? = nil
    var email:String? = nil
    var website:String? = nil
    var name = ""
    var details:String? = nil
    var categoryId:Int? = nil
    var categories_id:[Int]? = nil
    var uuid:String? = nil
    var sid:Int? = nil
    var audience:String? = nil
    var soliguideId:Int? = nil
    var soliguideUrl:String? = nil
    var source:String? = nil
    
    var openTimeTxt:String? = nil
    var languageTxt:String? = nil
    var latitude:Double? = nil
    var longitude:Double? = nil
    var image:UIImage {
        get {
            return getImage()
        }
    }
    let kImageNameFormat = "poi_category-new-%d"
    let kImageNamePoiDefault = "poi_category-new-0"
    
    func getImage() -> UIImage {
        var catId = self.categoryId
        //Fix Cat 4 deprecated until WS ready
        if (catId == 4) {
            catId = 41
        }
        let catID = catId != nil ? catId! : -1
        let imageName = String.init(format: kImageNameFormat, catID)
        let image:UIImage = (UIImage.init(named: imageName) != nil) ? UIImage.init(named: imageName)! : UIImage.init(named: kImageNamePoiDefault)!
        return image
    }
    enum CodingKeys: String, CodingKey {
        
        case partnerId = "partner_id"
        case address
        case phone
        case email
        case website
        case name
        case details = "description"
        case categoryId = "category_id"
        case uuid
        case sid = "id"
        case audience
        case soliguideId = "source_category_id"
        case soliguideUrl = "source_url"
        case source = "source"
        
        case openTimeTxt = "hours"
        case languageTxt = "languages"
        case latitude
        case longitude
        
        case categories_id = "category_ids"
    }
    
    func isSoliguide() -> Bool {
        return source == "soliguide"
    }
}
