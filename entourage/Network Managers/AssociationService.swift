//
//  AssociationService.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation

struct AssociationService {
    
    static func getAllAssociations( completion: @escaping (_ associations:[Partner]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetAllAssociations
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let associations = self.parseDataAssociations(data: data)
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
            
            let association = self.parseDataAssociation(data: data)
            DispatchQueue.main.async { completion(association,nil) }
        }
    }
    
    //MARK: - Parsing Assos -
    static func parseDataAssociations(data:Data) -> [Partner] {
        var associations = [Partner]()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let _jsonAssos = json["partners"] as? [[String:AnyObject]] {
                let decoder = JSONDecoder()
                for jsonAsso in _jsonAssos {
                    if let dataAsso = try? JSONSerialization.data(withJSONObject: jsonAsso) {
                        let asso = try decoder.decode(Partner.self, from:dataAsso)
                        associations.append(asso)
                    }
                }
            }
        }
        catch {
            Logger.print("Error parsing Asso \(error)")
        }
        return associations
    }
    
    static func parseDataAssociation(data:Data) -> Partner {
        var association = Partner()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let jsonAsso = json["partner"] as? [String:AnyObject] {
                let decoder = JSONDecoder()
                if let dataAsso = try? JSONSerialization.data(withJSONObject: jsonAsso) {
                    association = try decoder.decode(Partner.self, from:dataAsso)
                }
            }
        }
        catch {
            Logger.print("Error parsing Asso \(error)")
        }
        return association
    }
}
