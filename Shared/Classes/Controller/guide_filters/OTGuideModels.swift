//
//  OTGuideFiles.swift
//  entourage
//
//  Created by Jr on 18/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import Foundation


struct OTGuideFilters {
    var showFood = true
    var showHousing = true
    var showHeal = true
    var showRefresh = true
    var showOrientation = true
    var showCaring = true
    var showReinsertion = true
    
    var showPartners = true
    var showDonated = false
    var showVolunteer = false
    
    var arrayFilters = [OTGuideFilterItem]()
    
    init() {
        initArrayFilters()
    }
    
    private mutating func initArrayFilters() {
        
        if arrayFilters.count == 0 {
            arrayFilters = [OTGuideFilterItem.init(key: .SolidarityGuideKeyFood, active: showFood, image: "eat"),
                            OTGuideFilterItem.init(key: .SolidarityGuideKeyHousing, active: showHousing, image: "housing"),
                            OTGuideFilterItem.init(key: .SolidarityGuideKeyHeal, active: showHeal, image: "heal"),
                            OTGuideFilterItem.init(key: .SolidarityGuideKeyRefresh, active: showRefresh, image: "water"),
                            OTGuideFilterItem.init(key: .SolidarityGuideKeyOrientation, active: showOrientation, image: "orientate"),
                            OTGuideFilterItem.init(key: .SolidarityGuideKeyCaring, active: showCaring, image: "lookAfterYourself"),
                            OTGuideFilterItem.init(key: .SolidarityGuideKeyReinsertion, active: showReinsertion, image: "reinsertYourself")]
        }
    }
    
    func isDefaultFilters() -> Bool {
        if self.showDonated || self.showVolunteer {
            return false
        }
        
        if !showFood || !showHousing || !showHeal || !showRefresh || !showOrientation || !showCaring || !showReinsertion || !showPartners {
            return false
        }
        
        return true
    }
    
    func toDictionary(distance:CLLocationDistance, location:CLLocationCoordinate2D) -> [AnyHashable:Any]? {
        
        let catIds = NSMutableArray()
        
        for item in self.arrayFilters {
            if item.active {
                catIds.add(Int(item.key.rawValue))
            }
        }
        
        let catValuesString = catIds.componentsJoined(by: ",")
        
        if showPartners {
            let catValuesModString = catValuesString + ",8"
            var filters = ""
            if showDonated {
                filters = "donations"
                if showVolunteer {
                    filters = filters + ",volunteers"
                }
            }
            else if showVolunteer {
                filters = "volunteers"
            }
            
            return ["latitude":location.latitude,
                    "longitude":location.longitude,
                    "category_ids":catValuesModString,
                    "distance":distance,
                    "partners_filters":filters]
        }
        
        return ["latitude":location.latitude,
                "longitude":location.longitude,
                "category_ids":catValuesString,
                "distance":distance]
    }
    
    mutating func updateValueFilter(position:Int) {
        
        let item = arrayFilters[position]
        let isActive = item.active
        
        switch item.key {
        case .SolidarityGuideKeyFood:
            self.showFood = isActive
        case .SolidarityGuideKeyHousing:
            self.showHousing = isActive
        case .SolidarityGuideKeyHeal:
            self.showHeal = isActive
        case .SolidarityGuideKeyRefresh:
            self.showRefresh = isActive
        case .SolidarityGuideKeyOrientation:
            self.showOrientation = isActive
        case .SolidarityGuideKeyCaring:
            self.showCaring = isActive
        case .SolidarityGuideKeyReinsertion:
            self.showReinsertion = isActive
        case .SolidarityGuideKeyPartners:
            self.showPartners = isActive
        default:
            break
        }
    }
}

@objc class OTGuideFilterItem:NSObject {
    var key:GuideFilters = .none
    var active = false
    var title = ""
    var image = ""
    
    init(key:GuideFilters, active:Bool, image:String) {
        self.key = key
        self.active = active
        self.image = image
        self.title = OTGuideFilterItem.categoryStringForKey(key: key)
    }
    
    @objc static func categoryStringForKey(key:GuideFilters) -> String {
        switch (key) {
        case .SolidarityGuideKeyFood:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_feed")
        case .SolidarityGuideKeyHousing:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_housing")
        case .SolidarityGuideKeyHeal:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_heal")
        case .SolidarityGuideKeyRefresh:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_refresh")
        case .SolidarityGuideKeyOrientation:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_orientation")
        case .SolidarityGuideKeyCaring:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_caring")
        case .SolidarityGuideKeyReinsertion:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_reinsertion")
        case .SolidarityGuideKeyPartners:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_partners")
        default:
            return ""
        }
    }
}

//MARK: - Enum Guide filters -
@objc enum GuideFilters:Int {
    case SolidarityGuideKeyFood = 1
    case SolidarityGuideKeyHousing = 2
    case SolidarityGuideKeyHeal = 3
    case SolidarityGuideKeyRefresh = 4
    case SolidarityGuideKeyOrientation = 5
    case SolidarityGuideKeyCaring = 6
    case SolidarityGuideKeyReinsertion = 7
    case SolidarityGuideKeyPartners = 8
    case none = -1
}
