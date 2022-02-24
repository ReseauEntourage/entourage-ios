//
//  OTMessagesService.swift
//  entourage
//
//  Created by Jerome on 16/12/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation

@objc class OTMessagesService: NSObject {
    
    static func getMessagesOne2One(withParams params:[String:Any]?,andCompletion completion: @escaping ([OTEntourage]?, Error?) -> Void) {
        let token = UserDefaults.standard.currentUser.token
        let urlStr = String.init(format: API_URL_MESSAGES_ONE2ONE, token!)
       
        OTHTTPRequestManager.sharedInstance()?.get(withUrl: urlStr, andParameters: params, andSuccess: { (responseObj) in
            if let _resp = responseObj as? [String: Any] {
                var arrayFeeds = [OTEntourage]()
                if let arrayJson = _resp["entourages"] as? [[String: Any]] {
                    for item in arrayJson {
                        if let feeditem = OTEntourage.init(dictionary: item) {
                            arrayFeeds.append(feeditem)
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(arrayFeeds,nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(nil,nil)
                }
            }
        }, andFailure: { (error) in
            DispatchQueue.main.async {
                completion(nil,error)
            }
        })
    }
    
   @objc static func getMessagesGroup(withParams params:[String:Any]?,andCompletion completion: @escaping ([OTEntourage]?, Error?) -> Void) {
        let token = UserDefaults.standard.currentUser.token
        let urlStr = String.init(format: API_URL_MESSAGES_GROUP, token!)
       
        OTHTTPRequestManager.sharedInstance()?.get(withUrl: urlStr, andParameters: params, andSuccess: { (responseObj) in
            if let _resp = responseObj as? [String: Any] {
                var arrayFeeds = [OTEntourage]()
                if let arrayJson = _resp["entourages"] as? [[String: Any]] {
                    for item in arrayJson {
                        if let feeditem = OTEntourage.init(dictionary: item) {
                            arrayFeeds.append(feeditem)
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(arrayFeeds,nil)
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(nil,nil)
                }
            }
        }, andFailure: { (error) in
            DispatchQueue.main.async {
                completion(nil,error)
            }
        })
    }
    
    static func getMessagesMetadatas(withParams params:[String:Any]?,andCompletion completion: @escaping (MetadataMessagesCount?, Error?) -> Void) {
         let token = UserDefaults.standard.currentUser.token
         let urlStr = String.init(format: API_URL_MESSAGES_METADATA_COUNT, token!)
        
         OTHTTPRequestManager.sharedInstance()?.get(withUrl: urlStr, andParameters: params, andSuccess: { (responseObj) in
             if let _resp = responseObj as? [String: Any] {
                 let metadatas = MetadataMessagesCount(json: _resp)
                 
                 DispatchQueue.main.async {
                     completion(metadatas,nil)
                 }
             }
             else {
                 DispatchQueue.main.async {
                     completion(nil,nil)
                 }
             }
         }, andFailure: { (error) in
             DispatchQueue.main.async {
                 completion(nil,error)
             }
         })
     }
}

//MARK: - MetadataCount obj -

struct MetadataCount {
    var count: Int? = nil
    var unread:Int? = nil
    
    init(json:[String: Any]?) {
        count = json?["count"] as? Int
        unread = json?["unread"] as? Int
    }
}

struct MetadataMessagesCount {
    var conversations:MetadataCount
    var actions:MetadataCount
    var outings:MetadataCount
    
    init(json:[String: Any]) {
        conversations = MetadataCount(json: json["conversations"] as? [String : Any])
        actions = MetadataCount(json: json["actions"] as? [String : Any])
        outings = MetadataCount(json: json["outings"] as? [String : Any])
    }
}
