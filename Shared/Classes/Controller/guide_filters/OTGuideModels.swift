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
  //  var showRefresh = true
    var showOrientation = true
    var showCaring = true
    var showReinsertion = true
    
    var showPartners = true
    var showDonated = false
    var showVolunteer = false
    
    //New
    var showToilets = true
    var showDouches = true
    var showFontaines = true
    var showLaveLinges = true
    var showVetements = true
    var showBoitesDons = true
    
    var arrayFilters = [OTGuideFilterItem]()
    
    init() {
        initArrayFilters()
    }
    
    private mutating func initArrayFilters() {
        
        if arrayFilters.count == 0 {
            arrayFilters = [
                OTGuideFilterItem.init(key: .SolidarityGuideKeyFood, active: showFood, image: "picto_cat_filter-1"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyHousing, active: showHousing, image: "picto_cat_filter-2"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyHeal, active: showHeal, image: "picto_cat_filter-3"),
//                OTGuideFilterItem.init(key: .SolidarityGuideKeyRefresh, active: showRefresh, image: "picto_cat_filter-41"),
                
                OTGuideFilterItem.init(key: .SolidarityGuideKeyOrientation, active: showOrientation, image: "picto_cat_filter-5"),
                
                OTGuideFilterItem.init(key: .SolidarityGuideKeyCaring, active: showCaring, image: "picto_cat_filter-6"),
                
                OTGuideFilterItem.init(key: .SolidarityGuideKeyReinsertion, active: showReinsertion, image: "picto_cat_filter-7"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyToilett, active: showToilets, image: "picto_cat_filter-40"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyFontaines, active: showFontaines, image: "picto_cat_filter-41"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyDouches, active: showDouches, image: "picto_cat_filter-42"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyLaverLinge, active: showLaveLinges, image: "picto_cat_filter-43"),
                
                OTGuideFilterItem.init(key: .SolidarityGuideKeyVetements, active: showVetements, image: "picto_cat_filter-61"),
                OTGuideFilterItem.init(key: .SolidarityGuideKeyBoitesDons, active: showBoitesDons, image: "picto_cat_filter-62")]
        }
    }
    
    func isDefaultFilters() -> Bool {
        if self.showDonated || self.showVolunteer {
            return false
        }
        
        if !showFood || !showHousing || !showHeal || !showOrientation || !showCaring || !showReinsertion || !showPartners || !showToilets || !showFontaines || !showDouches || !showLaveLinges || !showVetements || !showBoitesDons {
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
        case .SolidarityGuideKeyOrientation:
            self.showOrientation = isActive
        case .SolidarityGuideKeyCaring:
            self.showCaring = isActive
        case .SolidarityGuideKeyReinsertion:
            self.showReinsertion = isActive
        case .SolidarityGuideKeyPartners:
            self.showPartners = isActive
            
        case .SolidarityGuideKeyToilett:
            self.showToilets = isActive
        case .SolidarityGuideKeyFontaines:
            self.showFontaines = isActive
        case .SolidarityGuideKeyDouches:
            self.showDouches = isActive
        case .SolidarityGuideKeyLaverLinge:
            self.showLaveLinges = isActive
            
        case .SolidarityGuideKeyVetements:
            self.showVetements = isActive
        case .SolidarityGuideKeyBoitesDons:
            self.showBoitesDons = isActive
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
        case .SolidarityGuideKeyOrientation:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_orientation")
        case .SolidarityGuideKeyCaring:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_caring")
        case .SolidarityGuideKeyReinsertion:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_reinsertion")
        case .SolidarityGuideKeyPartners:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_partners")
            
        case .SolidarityGuideKeyToilett:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_toilettes")
        case .SolidarityGuideKeyFontaines:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_fontaines")
        case .SolidarityGuideKeyDouches:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_laver")
        case .SolidarityGuideKeyLaverLinge:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_laverie")
            
        case .SolidarityGuideKeyVetements:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_vetements")
        case .SolidarityGuideKeyBoitesDons:
            return OTLocalisationService.getLocalizedValue(forKey: "guide_display_boite")
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
   // case SolidarityGuideKeyRefresh = 4 deprecated
    case SolidarityGuideKeyOrientation = 5
    case SolidarityGuideKeyCaring = 6
    case SolidarityGuideKeyReinsertion = 7
    case SolidarityGuideKeyPartners = 8
    case none = -1
    
    //Nouveau
    case SolidarityGuideKeyToilett = 40
    case SolidarityGuideKeyFontaines = 41
    case SolidarityGuideKeyDouches = 42
    case SolidarityGuideKeyLaverLinge = 43
    
    case SolidarityGuideKeyVetements = 61
    case SolidarityGuideKeyBoitesDons = 62
}
