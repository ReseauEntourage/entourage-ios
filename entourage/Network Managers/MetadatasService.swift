//
//  MetadatasService.swift
//  entourage
//
//  Created by Jerome on 14/03/2022.
//

import Foundation


struct MetadatasService {

    static func getMetadatas( completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIMetadatas
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            parseTagsInterests(data: data)
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    private static func parseTagsInterests(data:Data) {
        Metadatas.sharedInstance.addTagsInterests(data: data)
    }
}
