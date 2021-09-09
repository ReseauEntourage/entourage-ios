//
//  HomeCard.swift
//  entourage
//
//  Created by Jr on 11/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation

//MARK: - HomeCard Object -
struct HomeCard {
    var titleSection = ""
    var type = HomeCardType.None
    var subtype = HomeCardType.None
    var arrayCards = [Any]()
    
    static func parseHomeCard(array:[Any],name:String) -> HomeCard {
        var homeCard = HomeCard()
        homeCard.titleSection = OTLocalisationService.getLocalizedValue(forKey: name+"_title_home")
        homeCard.type = HomeCardType.getTypeFromName(name: name)
        homeCard.subtype = HomeCardType.getSubTypeFromName(name: name)
        homeCard.arrayCards = [Any]()
        
        if homeCard.type == .Headlines {
            return homeCard
        }
        
        for _item in array {
            if let _dict = _item as? [String:Any] {
                var feedItem:OTFeedItem? = nil
                
                if homeCard.type == .Actions || homeCard.type == .Events {
                    feedItem = OTEntourage.init(dictionary: _dict)
                }
                
                if let _feedItem = feedItem {
                    homeCard.arrayCards.append(_feedItem)
                }
            }
        }
        return homeCard
    }
    
    static func parseHomeCard(dictionary:[String:Any],name:String) -> HomeCard {
        var homeCard = HomeCard()
        homeCard.titleSection = OTLocalisationService.getLocalizedValue(forKey: name+"_title_home")
        homeCard.type = HomeCardType.getTypeFromName(name: name)
        homeCard.arrayCards = [Any]()
        
        if homeCard.type == .Headlines {
            if let _meta = dictionary["metadata"] as? [String:Any], let _order = _meta["order"] as? [String]  {
                for _item in _order {
                    if let _dict = dictionary[_item] as? [String:Any] {
                        if let type = _dict["type"] as? String, let data = _dict["data"] as? [String:Any] {
                            var feedItem:OTFeedItem? = nil
                            
                            if type == "Announcement" {
                                feedItem = OTAnnouncement.init(dictionary: data)
                            }
                            else if type == "Entourage" {
                                feedItem = OTEntourage.init(dictionary: data)
                            }
                            
                            if let _feedItem = feedItem {
                                homeCard.arrayCards.append(_feedItem)
                            }
                        }
                    }
                }
            }
        }
        return homeCard
    }
    
    static func parsingFeed(dict:[String:Any]) -> [HomeCard]? {
        var returnFeed:[HomeCard]? = nil
        
        if let _meta = dict["metadata"] as? [String:Any], let _order = _meta["order"] as? [String]  {
            returnFeed = [HomeCard]()
            for _item in _order {
                
                if let _array = dict[_item] as? [Any] {
                    returnFeed?.append(HomeCard.parseHomeCard(array: _array,name: _item))
                }
                else {
                    if let _dict = dict[_item] as? [String:Any] {
                        returnFeed?.append(HomeCard.parseHomeCard(dictionary: _dict, name: _item))
                    }
                }
            }
        }
        return returnFeed
    }
}

//MARK: - HomeCardType -
enum HomeCardType {
    case Headlines
    case Events
    case Actions
    case ActionsAsk
    case ActionsContrib
    case None
    
    static func getTypeFromName(name:String) -> HomeCardType {
        switch name {
        case "entourages","entourage_ask_for_helps","entourage_contributions":
            return .Actions
        case "outings":
            return .Events
        case "headlines":
            return .Headlines
        default:
            return .None
        }
    }
    
    static func getSubTypeFromName(name:String) -> HomeCardType {
        switch name {
        case "entourage_ask_for_helps":
            return .ActionsAsk
        case "entourage_contributions":
            return .ActionsContrib
        default:
            return .None
        }
    }
}
