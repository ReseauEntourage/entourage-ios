//
//  OTNewFeedsService.swift
//  entourage
//
//  Created by Jr on 10/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation


class OTNewFeedsService {
    
    static func getFeed(withParams params:[String:Any]?,andCompletion completion: @escaping ([HomeCard]?, Error?) -> Void) {
        let token = UserDefaults.standard.currentUser.token
        let urlStr = String.init(format: API_URL_NEW_FEED, token!)
       
        OTHTTPRequestManager.sharedInstance()?.get(withUrl: urlStr, andParameters: params, andSuccess: { (responseObj) in
            if let _resp = responseObj as? [String: Any] {
               let _array = HomeCard.parsingFeed(dict: _resp)
                DispatchQueue.main.async {
                    completion(_array,nil)
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
