//
//  OTShareEntourageService.swift
//  entourage
//
//  Created by Jr on 07/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import Foundation


struct OTShareEntourageService {
    
    static func getAllShareEntourage(completion: @escaping (_ result: [String:Any]?)->()) {
        let manager = OTHTTPRequestManager.sharedInstance()
        if let token = UserDefaults.standard.currentUser.token {
            
            let url = String.init(format: API_URL_SHARINGS, token)
            manager?.get(withUrl: url, andParameters: nil, andSuccess: { (response) in
                if let _dict = response as? [String:Any] {
                    completion(_dict)
                }
                else {
                    completion(nil)
                }
            }, andFailure: { (error) in
                Logger.print("Error get Share : \(String(describing: error?.localizedDescription))")
            })
        }
    }
    
    static func postAddShare(entourageId:String,uuid:String,completion: @escaping (_ isOk: Bool)->()) {
        let manager = OTHTTPRequestManager.sharedInstance()
        if let token = UserDefaults.standard.currentUser.token {
            let url = String.init(format: API_URL_ENTOURAGE_SEND_MESSAGE,entourageId, token)
            
            let params:[String:Any] = ["chat_message":["message_type":"share","metadata":["type":"entourage","uuid":uuid]]]
            
            manager?.post(withUrl: url, andParameters: params, andSuccess: { (response) in
                completion(true)
            }, andFailure: { (error) in
                Logger.print("***** return post Share error \(String(describing: error))")
                completion(false)
            })
        }
    }
}
