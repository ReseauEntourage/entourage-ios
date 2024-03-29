//
//  PoiCategory.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import Foundation
import UIKit

struct PoiCategory {
    var sid:Int? = 0
    var name:String = ""
    var color:UIColor?
    
    
    mutating func updateInfos() {
        self.color = PoiCategory.colorForCategoryId(sid: sid)
        self.name = PoiCategory.nameForCategoryId(sid: sid)
    }
    
    static func colorForCategoryId(sid:Int?) -> UIColor {
        if sid == nil { return UIColor.poiCategory0 }
        switch sid {
        case 1:
            return UIColor.poiCategory1
        case 2:
            return UIColor.poiCategory2
        case 3:
            return UIColor.poiCategory3
        case 4, 40,41,42,43:
            return UIColor.poiCategory4
        case 5:
            return UIColor.poiCategory5
        case 6,61,62:
            return UIColor.poiCategory6
        case 7:
            return UIColor.poiCategory7
        case 8:
            return UIColor.poiCategory8
        default:
            return UIColor.poiCategory0
        }
    }
    
    static func nameForCategoryId(sid:Int?) -> String {
        if sid == nil {return "--"}
            switch (sid) {
                case 1:
                    return "Category_Food".localized
                case 2:
                    return "Category_Accommodation".localized
                case 3:
                    return "Category_Health".localized
                case 4:
                    return "Category_Refresh".localized
                case 40:
                    return "Category_Toilets".localized
                case 41:
                    return "Category_Fountains".localized
                case 42:
                    return "Category_Wash".localized
                case 43:
                    return "Category_Laundries".localized
                case 5:
                    return "Category_Orient".localized
                case 6:
                    return "Category_SelfCare".localized
                case 61:
                    return "Category_Clothes".localized
                case 62:
                    return "Category_DonationBox".localized
                case 7:
                    return "Category_Reintegration".localized
                case 8:
                    return "Category_Partners".localized
                default:
                    return "Category_Other".localized
                }
    }
}
