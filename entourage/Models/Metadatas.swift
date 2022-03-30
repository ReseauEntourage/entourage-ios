//
//  Metadatas.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import Foundation


class Metadatas:Codable {
    static let sharedInstance = Metadatas()
    var tagsInterests:TagsInterests? = nil
    var tagsSignals:TagsSignals? = nil
    
    
    private init() {}
    
    func parseMetadatas(data:Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                if let tags = json["tags"] as? [String:AnyObject] {
                    addTagsInterests(json: tags)
                    addTagsSignals(json: tags)
                }
            }
        }
        catch {
            Logger.print("Error parsing \(error)")
        }
    }
    
    func addTagsInterests(json:[String: AnyObject] ) {
        if let _interests = json["interests"] as? [[String:String]] {
            tagsInterests = TagsInterests()
            
            for _interest in _interests {
                if let interest = _interest.first {
                    tagsInterests?.interests.append(Interest(keyName: interest.key, keyValue: interest.value))
                }
            }
        }
    }
    
    func addTagsSignals(json:[String: AnyObject] ) {
        if let _signals = json["signals"] as? [[String:String]] {
            tagsSignals = TagsSignals()
            
            for _signal  in _signals {
                if let signal = _signal.first {
                    tagsSignals?.signals.append(Signal(keyName: signal.key, keyValue: signal.value))
                }
            }
        }
    }
}

//MARK: - TagsInterests -
struct TagsInterests:Codable {
    fileprivate var interests = [Interest]()
    
    //Use for bubble categories interests
    func getTagInterestName(key:String) -> String {
        if let tag = interests.first(where: {$0.tagKey == key }) {
            return tag.tagName
        }
        return key
    }
    
    func getInterests() -> [Interest] {
        return interests
    }
    
    mutating func checkUncheckInterestFrom(key:String, isCheck:Bool) {
        if let pos = interests.firstIndex(where: {$0.tagKey == key }) {
            self.interests[pos].isSelected = isCheck
        }
    }
    
    mutating func checkUncheckInterestFrom(position:Int, isCheck:Bool) {
        if position < interests.count {
            self.interests[position].isSelected = isCheck
        }
    }
    
    func getInterestsForWS() -> [String] {
        var arrayForWS = [String]()
        for interest in interests {
            if interest.isSelected {
                arrayForWS.append(interest.tagKey)
            }
        }
        return arrayForWS
    }
}
//MARK: - Interest -
struct Interest:Codable {
    fileprivate var tagName:String
    fileprivate var tagKey:String
    
    var tagImageName:String? {
        get {
            return InterestMappingImageHelper.getInterestImageNameFromKey(key: tagKey)
        }
    }
    var name: String {
        return tagName
    }
    var isSelected = false
    
    init(keyName:String,keyValue:String) {
        tagName = keyValue
        tagKey = keyName
    }
}

fileprivate struct InterestMappingImageHelper {
    static func getInterestImageNameFromKey(key:String) -> String {
        var imageName = "others"
        
        switch key {
        case "activites":
            imageName = "interest_activities"
        case "animaux":
            imageName = "interest_animals"
        case "bien-etre":
            imageName = "interest_wellness"
        case "cuisine":
            imageName = "interest_cooking"
        case "culture":
            imageName = "interest_art"
        case "jeux":
            imageName = "interest_game"
        case "sport":
            imageName = "interest_sport"
        case "nature":
            imageName = "interest_nature"
        default:
            imageName = "others"
        }
        return imageName
    }
}

//MARK: - Signals -
struct TagsSignals:Codable {
    fileprivate var signals = [Signal]()
    
    func getTagSignalName(key:String) -> String {
        if let tag = signals.first(where: {$0.signalKey == key }) {
            return tag.signalName
        }
        return key
    }
    
    func getSignals() -> [Signal] {
        return signals
    }
    
    mutating func checkUncheckSignalFrom(position:Int, isCheck:Bool) {
        if position < signals.count {
            self.signals[position].isSelected = isCheck
        }
    }
    
    func getSignalsForWS() -> [String] {
        var arrayForWS = [String]()
        for signal in signals {
            if signal.isSelected {
                arrayForWS.append(signal.signalKey)
            }
        }
        return arrayForWS
    }
}
//MARK: - Signal -
struct Signal:Codable {
    fileprivate var signalName:String
    fileprivate var signalKey:String
    
    var name: String {
        return signalName
    }
    var isSelected = false
    
    init(keyName:String,keyValue:String) {
        signalName = keyValue
        signalKey = keyName
    }
}
