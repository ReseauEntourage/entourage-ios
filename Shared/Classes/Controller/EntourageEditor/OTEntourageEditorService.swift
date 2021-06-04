//
//  OTEntourageEditorService.swift
//  entourage
//
//  Created by Jr on 19/05/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation


class OTEntourageEditorService {
    
    static func getGalleryPhoto(withParams params:[String:Any]?,andCompletion completion: @escaping ([PhotoGallery]?, Error?) -> Void) {
        let token = UserDefaults.standard.currentUser.token
        let urlStr = String.init(format: API_URL_ENTOURAGES_IMAGES, token!)
       
        OTHTTPRequestManager.sharedInstance()?.get(withUrl: urlStr, andParameters: params, andSuccess: { (responseObj) in
            if let _resp = responseObj as? [String: Any] {
                let _array = PhotoGallery.parsingPhotos(dict: _resp)
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

