//
//  AssociationService.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation

struct AssociationService:ParsingDataCodable {
    
    static func getAllAssociations( completion: @escaping (_ associations:[Partner]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetAllAssociations
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let associations:[Partner]? = self.parseDatas(data: data,key: "partners")
            DispatchQueue.main.async { completion(associations,nil) }
        }
    }
    
    static func getPartnerDetail(id:Int, completion: @escaping (_ associations:Partner?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetDetailAssociation
        endpoint = String.init(format: endpoint,id, token)
        
        Logger.print("***** url get detail asso : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let association:Partner? = self.parseData(data: data,key: "partner")
            DispatchQueue.main.async { completion(association,nil) }
        }
    }
}
