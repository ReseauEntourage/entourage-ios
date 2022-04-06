//
//  PoiService.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import Foundation

struct PoiService:ParsingDataCodable {

    static func getPois(params:[String:String], completion: @escaping (_ pois:[MapPoi]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        let endpoint = kAPIPois
        
        var parameters = params
        parameters["token"] = token
        Logger.print("***** getPois params : \(params)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: parameters) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let pois:[MapPoi]? = self.parseDatas(data: data,key: "pois")
            DispatchQueue.main.async { completion(pois,nil) }
        }
    }
    
    static func getDetailPoiWith(poiId:String, completion: @escaping (_ poi:MapPoi?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        let endpoint = "\(kAPIPois)/\(poiId)"
        
        let parameters = ["token":token]
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: parameters) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let poi:MapPoi? = self.parseData(data: data,key: "poi")
            DispatchQueue.main.async { completion(poi,nil) }
        }
    }
}
