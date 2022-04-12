//
//  Metadatas.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import Foundation
import SwiftUI


class Metadatas:Codable {
    static let sharedInstance = Metadatas()
    private var _tagsInterests:Tags? = nil
    private var _tagsSignals:Tags? = nil
    
    
    private init() {}
    
    var tagsInterest:Tags? {
        get {
            guard let tags = _tagsInterests?.tags else { return nil }
            
            for tag in tags {
                tag.isSelected = false
            }
            self._tagsInterests?.tags = tags
            return self._tagsInterests
        }
    }
    
    var tagsSignals:Tags? {
        get {
            guard let tags = _tagsSignals?.tags else { return nil }
            
            for tag in tags {
                tag.isSelected = false
            }
            self._tagsSignals?.tags = tags
            return self._tagsSignals
        }
    }
    
    func parseMetadatas(data:Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                if let tags = json["tags"] as? [String:AnyObject] {
                    addTags(json: tags, key: "interests", tags: &_tagsInterests)
                    addTags(json: tags, key: "signals", tags: &_tagsSignals)
                }
            }
        }
        catch {
            Logger.print("Error parsing \(error)")
        }
    }
    
    func addTags(json:[String: AnyObject], key:String, tags:inout Tags? ) {
        if let _interests = json[key] as? [[String:String]] {
            tags = Tags()
            for _interest in _interests {
                if let _key:String = _interest["id"], let _value:String = _interest["name"] {
                    tags?.tags.append(TagInterest(keyName: _key, keyValue: _value))
                }
            }
        }
    }
}

//MARK: - Tags -
struct Tags:Codable {
    fileprivate var tags = [Tag]()
    
    func getTagNameFrom(key:String) -> String {
        if let tag = tags.first(where: {$0.tagKey == key }) {
            return tag.tagName
        }
        return key
    }
    
    func getTags() -> [Tag] {
        return tags
    }
    
    mutating func addTag(tag:Tag) {
        tags.append(tag)
    }
    
    mutating func checkUncheckTagFrom(key:String, isCheck:Bool) {
        if let pos = tags.firstIndex(where: {$0.tagKey == key }) {
            self.tags[pos].isSelected = isCheck
        }
    }
    
    mutating func checkUncheckTagFrom(position:Int, isCheck:Bool) {
        if position < tags.count {
            self.tags[position].isSelected = isCheck
        }
    }
    
    func getTagsForWS() -> [String] {
        var arrayForWS = [String]()
        for interest in tags {
            if interest.isSelected {
                arrayForWS.append(interest.tagKey)
            }
        }
        return arrayForWS
    }
}

//MARK: - Tag -
class Tag:Codable {
    fileprivate var tagName:String
    fileprivate var tagKey:String
    
    
    var name: String {
        return tagName
    }
    var key: String {
        return tagKey
    }
    var isSelected = false
    
    init(keyName:String,keyValue:String) {
        tagName = keyValue
        tagKey = keyName
    }
}

//MARK: - Tag interest -
class TagInterest: Tag {
    var tagImageName:String? {
        get {
            return InterestMappingImageHelper.getInterestImageNameFromKey(key: self.tagKey)
        }
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
            imageName = "interest_others"
        }
        return imageName
    }
}
