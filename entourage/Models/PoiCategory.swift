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
            return "Se nourrir"
        case 2:
            return "Se loger"
        case 3:
            return "Se soigner"
        case 4:
            return "Se rafraîchir"
        case 40:
            return "Toilettes"
        case 41:
            return "Fontaines"
        case 42:
            return "Se laver"
        case 43:
            return "Laveries"
        case 5:
            return "S'orienter"
        case 6:
            return "S'occuper de soi"
        case 61:
            return "Vêtements & matériels"
        case 62:
            return "Boite à dons/lire"
        case 7:
            return "Se réinsérer"
        case 8:
            return "Partenaires"
        default:
            return "Autre"
        }
    }
}
