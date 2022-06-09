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
}
