//
//  OTHomeNeoService.swift
//  entourage
//
//  Created by Jr on 14/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation


class OTHomeNeoService {
    
    static func getAreas(completion: @escaping ([OTHomeTourArea]?, Error?) -> Void) {
        let token = UserDefaults.standard.currentUser.token
        let urlStr = String.init(format: API_URL_TOUR_AREAS, token!)
        
        OTHTTPRequestManager.sharedInstance()?.get(withUrl: urlStr, andParameters: nil, andSuccess: { (responseObj) in
            if let _resp = responseObj as? [String: Any] {
                let _array = OTHomeTourArea.parsingAreas(dict: _resp)
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
    
    static func sendAnswer(withId areaId:Int,andCompletion completion: @escaping (Error?) -> Void) {
        let token = UserDefaults.standard.currentUser.token
        let urlStr = String.init(format: API_URL_TOUR_AREAS_ANSWER,areaId, token!)
        
        OTHTTPRequestManager.sharedInstance()?.post(withUrl: urlStr, andParameters: nil, andSuccess: { (responseObj) in
            DispatchQueue.main.async {
                completion(nil)
            }
        }, andFailure: { (error) in
            DispatchQueue.main.async {
                completion(error)
            }
        })
    }
}
