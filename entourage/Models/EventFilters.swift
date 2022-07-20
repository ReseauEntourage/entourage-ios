//
//  EventFilters.swift
//  entourage
//
//  Created by Jerome on 20/07/2022.
//

import Foundation

//MARK: - Structure Event Filter -
struct EventFilters {
    private var radius_distance:Int? = nil
    private var eventLocation:EventLocation? = nil
    private var shortname:String? = nil
    private var name:String? = nil
    
    private var selectedType:EventFilterType = .profile
    
    init() {
        setCurrentProfileFilters()
    }
    
    mutating func resetToDefault() {
        setCurrentProfileFilters()
    }
    
    func getFilterButtonString() -> String {
        guard let name = shortname, let radius_distance = radius_distance else {
            return "location".localized
        }
        
        return "\(name) - \(radius_distance) km"
    }
    
    mutating func modifyRadius(_ radius_distance:Int) {
        self.radius_distance = radius_distance
    }
    
    mutating func modifyFilter(name:String?,shortname:String?,eventLocation:EventLocation?,radius_distance:Int,type:EventFilterType) {
        self.radius_distance = radius_distance
        self.selectedType = type
        self.eventLocation = eventLocation
        self.name = name
        self.shortname = shortname
    }
    
    var filterType:EventFilterType {
        get {
            return selectedType
        }
    }
    
    var radius:Int {
        get {
            return radius_distance ?? 0
        }
    }
    
    var addressName:String {
        get {
            return name ?? "-"
        }
    }
    var addressNameShort:String {
        get {
            return shortname ?? "-"
        }
    }
    
    func getfiltersForWS() -> String? {
        var params = ""
        
        if selectedType == .profile {
            guard let radius_distance = radius_distance else {
                return nil
            }
            params = "travel_distance=\(radius_distance)"
        }
        else {
            guard let _lat = eventLocation?.latitude, let _long = eventLocation?.longitude, let _radius = radius_distance else {
                return nil
            }
            params = "travel_distance=\(_radius)&latitude=\(_lat)&longitude=\(_long)"
        }
        return params
    }
    
    func validate() -> Bool {
        if eventLocation == nil || name == nil || radius_distance == nil {
            return false
        }
        return true
    }
    
    private mutating func setCurrentProfileFilters() {
        if let user = UserDefaults.currentUser {
            radius_distance = user.radiusDistance
            let _lat = user.addressPrimary?.latitude
            let _long = user.addressPrimary?.longitude
            eventLocation = EventLocation(latitude: _lat, longitude: _long)
            name = user.addressPrimary?.displayAddress
            shortname = user.addressPrimary?.displayAddress
            selectedType = .profile
        }
    }
    
    enum EventFilterType {
        case profile
        case google
        case gps
    }
}
