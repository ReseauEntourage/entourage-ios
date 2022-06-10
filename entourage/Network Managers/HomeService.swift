//
//  HomeService.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import Foundation
struct HomeService:ParsingDataCodable {
    
    static func getUserHome( completion: @escaping (_ userHome:UserHome?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIHomeSummary
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let userHome:UserHome? = self.parseData(data: data,key: "user")
            DispatchQueue.main.async { completion(userHome,nil) }
        }
    }
    
    //Resources
    static func getResources( completion: @escaping (_ resources:[PedagogicResource]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIHomeResources
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let resources:[PedagogicResource]? = self.parseDatas(data: data,key: "resources")
            DispatchQueue.main.async { completion(resources, nil) }
        }
    }
    
    static func postResourceRead( resourceId:Int, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIHomeResourceRead
        endpoint = String.init(format: endpoint,resourceId, token)
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
}
