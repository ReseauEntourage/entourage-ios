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

struct TagsInterests:Codable {
    fileprivate var interests = [Interest]()
    
    func getTagInterestName(key:String) -> String {
        if let tag = interests.first(where: {$0.tagKey == key }) {
            return tag.tagName
        }
        return key
    }
}

struct Interest:Codable {
    fileprivate var tagName:String
    fileprivate var tagKey:String
    
    init(keyName:String,keyValue:String) {
        tagName = keyValue
        tagKey = keyName
    }
}
