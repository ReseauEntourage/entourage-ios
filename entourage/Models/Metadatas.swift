//
//  Metadatas.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import Foundation


class Metadatas:Codable {
    static let sharedInstance = Metadatas()
    private var _tagsInterests:Tags? = nil
    private var _tagsSignals:Tags? = nil
    private var _tagsSections:Sections? = nil
    
    private init() {}
    
    var tagsSections:Sections? {
        get {
            guard let tags = _tagsSections?.sections else { return nil }
            
            for tag in tags {
                tag.isSelected = false
            }
            self._tagsSections?.sections = tags
            return self._tagsSections
        }
    }
    
    func getTagSectionName(key:String) -> (name:String,subtitle:String)? {
      return _tagsSections?.getSectionNameFrom(key: key)
    }
    
    func getTagSectionImageName(key:String) -> String? {
        return _tagsSections?.getSectionFrom(key: key)?.getImageName()
    }
    
    
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
                    addSections(json: tags, key: "sections", tags: &_tagsSections)
                }
                if let reactionsArray = json["reactions"] as? [[String: AnyObject]] {
                    let reactionsData = try JSONSerialization.data(withJSONObject: reactionsArray)
                    let reactions = try JSONDecoder().decode([ReactionType].self, from: reactionsData)
                    UserDefaults.standard.set(reactionsData, forKey: "StoredReactions")

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
    
    func addSections(json:[String:AnyObject], key:String, tags:inout Sections?) {
        if let _interests = json[key] as? [[String:String]] {
            tags = Sections()
            for _interest in _interests {
                if let _key:String = _interest["id"], let _name:String = _interest["name"], let _subtitle:String = _interest["subname"] {
                    tags?.sections.append(Section(keyName: _key, keyValue: _name, keySubtitle: _subtitle))
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
            return TagsUtils.showTagTranslated(tag.tagKey)
        }
        return key
    }
    
    func getTags() -> [Tag] {
        return tags
    }
    
    func hasTagSelected() -> Bool {
        var isValidTag = false
        for tag in tags {
            if tag.isSelected {
                isValidTag = true
                break
            }
        }
        return isValidTag
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
    static let tagOther = "other"
    
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
    
    static func getSmallImageTagFrom(tag:String) -> String {
        return InterestMappingImageHelper.getInterestSmallImageNameFromKey(key: tag)
    }
}

fileprivate struct InterestMappingImageHelper {
    static func getInterestImageNameFromKey(key: String) -> String {
        var imageName = "enhanced_onboarding_interest_other"

        switch key {
        case "activites":
            imageName = "interest_activite-manuelle"
        case "animaux":
            imageName = "interest_animaux"
        case "bien-etre":
            imageName = "interest_bien-etre"
        case "cuisine":
            imageName = "interest_cuisine"
        case "culture":
            imageName = "interest_art"
        case "jeux":
            imageName = "interest_jeux"
        case "sport":
            imageName = "interest_sport"
        case "nature":
            imageName = "interest_nature"
        case "marauding":
            imageName = "interest_rencontre-nomade"
        default:
            imageName = "enhanced_onboarding_interest_other"
        }
        return imageName
    }
    
    static func getInterestSmallImageNameFromKey(key:String) -> String {
        var imageName = "enhanced_onboarding_interest_other"
        
        switch key {
        case "activites":
            imageName = "interest_small_activities"
        case "animaux":
            imageName = "interest_small_animals"
        case "bien-etre":
            imageName = "interest_small_wellness"
        case "cuisine":
            imageName = "interest_small_cooking"
        case "culture":
            imageName = "interest_small_art"
        case "jeux":
            imageName = "interest_small_game"
        case "sport":
            imageName = "interest_small_sport"
        case "nature":
            imageName = "interest_small_nature"
        case "marauding":
            imageName = "interest_small_nomad"
        default:
            imageName = "interest_small_others"
        }
        return imageName
    }
}


//MARK: - Sections -
struct Sections:Codable {
    fileprivate var sections = [Section]()
    
    func getSectionNameFrom(key:String) -> (name:String,subtitle:String) {
        return (TagsUtils.showTagTranslated(key), TagsUtils.showSubTagTranslated(key))
        if let cat = sections.first(where: {$0.catKey == key }) {
            return (cat.catName, cat.catSubtitle)
        }
        return (key,key)
    }
    
    func getSectionFrom(key:String) -> Section? {
        if let cat = sections.first(where: {$0.catKey == key }) {
            return cat
        }
        return nil
    }
    
    func getSections() -> [Section] {
        return sections
    }
    
    func hasSectionSelected() -> Bool {
        var isValidTag = false
        for tag in sections {
            if tag.isSelected {
                isValidTag = true
                break
            }
        }
        return isValidTag
    }
    
    mutating func setSectionSelected(key:String) {
        var i = 0
        for _ in sections {
            sections[i].isSelected = false
            i = i + 1
        }
        
        if let pos = sections.firstIndex(where: {$0.catKey == key }) {
            self.sections[pos].isSelected = true
        }
    }
    
    func getSectionForWS() -> String {
        var key = ""
        if let cat = sections.first(where: {$0.isSelected == true }) {
            key = cat.catKey
        }
        return  key
    }
    
    func getnumberSectionsSelected() -> Int {
        var count = 0
        
        for tag in sections {
            if tag.isSelected {
                count = count + 1
            }
        }
        return count
    }
    
    func getallSectionforWS() -> String? {
        var _values = ""
        
        for tag in sections {
            if tag.isSelected {
                let _coma = _values.count > 0 ? "," : ""
                _values = _values + _coma + tag.catKey
            }
        }
        return _values.count > 0 ? _values : nil
    }
    
    mutating func resetToDefault() {
        var i = 0
        for _ in sections {
            sections[i].isSelected = false
            i = i + 1
        }
    }
}

//MARK: - Section -
class Section:Codable {
    fileprivate var catName:String
    fileprivate var catSubtitle:String
    fileprivate var catKey:String
    
    var name: String {
        return catName
    }
    var subtitle:String {
        return catSubtitle
    }
    var key: String {
        return catKey
    }
    var isSelected = false
    
    init(keyName:String,keyValue:String, keySubtitle:String) {
        catName = keyValue
        catKey = keyName
        catSubtitle = keySubtitle
    }
    
    func getImageName() -> String {
        switch catKey {
        case "social":
            return "ic_action_social"
        case "clothes":
            return "ic_action_clothes"
        case "equipment":
            return "ic_action_equipment"
        case "hygiene":
            return "ic_action_hygiene"
        case "services":
            return "ic_action_services"
        default:
            return ""
        }
    }
}
