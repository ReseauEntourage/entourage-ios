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
}
