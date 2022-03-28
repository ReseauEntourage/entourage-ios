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
    
    private init() {}
    
    func addTagsInterests(data:Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                if let _tags = json["tags"] as? [String:AnyObject], let _interests = _tags["interests"] as? [String:String] {
                    tagsInterests = TagsInterests()
                    
                    for (_key,_value) in _interests {
                        tagsInterests?.interests.append(Interest(keyName: _key, keyValue: _value))
                    }
                }
            }
        }
        catch {
            Logger.print("Error parsing \(error)")
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
