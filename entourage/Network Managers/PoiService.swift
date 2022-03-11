//
//  PoiService.swift
//  entourage
//
//  Created by Jerome on 20/01/2022.
//

import Foundation

struct PoiService {

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
            
            let pois = self.parseDataPois(data: data)
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
            
            let poi = self.parseDataPoi(data: data)
            DispatchQueue.main.async { completion(poi,nil) }
        }
    }
    
    //MARK: - Parsing Assos -
    static func parseDataPois(data:Data) -> [MapPoi] {
        var pois = [MapPoi]()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let _jsonPois = json["pois"] as? [[String:AnyObject]] {
                let decoder = JSONDecoder()
                for jsonPoi in _jsonPois {
                    if let dataPoi = try? JSONSerialization.data(withJSONObject: jsonPoi) {
                        let poi = try decoder.decode(MapPoi.self, from:dataPoi)
                        pois.append(poi)
                    }
                }
            }
        }
        catch {
            Logger.print("Error parsing pois \(error)")
        }
        return pois
    }
    
    static func parseDataPoi(data:Data) -> MapPoi {
        var poi = MapPoi()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let _jsonPoi = json["poi"] as? [String:AnyObject] {
                let decoder = JSONDecoder()
                
                if let dataPoi = try? JSONSerialization.data(withJSONObject: _jsonPoi) {
                    let _poi = try decoder.decode(MapPoi.self, from:dataPoi)
                    poi = _poi
                }
            }
        }
        catch {
            Logger.print("Error parsing pois \(error)")
        }
        return poi
    }
}
