//
//  NeighborhoodService.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation

struct NeighborhoodService {
    
    static func getAllNeighborhoods( completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINeighborhoods
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group = self.parseDataNeighborhoods(data: data)
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    static func getNeighborhoodDetail(id:Int, completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetDetailNeighborhood
        endpoint = String.init(format: endpoint,"\(id)", token)
        
        Logger.print("***** url get detail group : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group = self.parseDataNeighborhood(data: data)
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    //MARK: - Create/update group -
    static func createNeighborhood(group:Neighborhood,completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINeighborhoods
        endpoint = String.init(format: endpoint, token)

        let parameters = ["neighborhood" : group.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed post group \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post group: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post group - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let group = self.parseDataNeighborhood(data: data)
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    
    static func updateNeighborhood(group:Neighborhood,completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUpdateNeighborhood
        endpoint = String.init(format: endpoint,"\(group.uid)", token)

        let parameters = ["neighborhood" : group.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update group \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response update group: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update group - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let group = self.parseDataNeighborhood(data: data)
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    
    
    //MARK: - Parsing Assos -
    static func parseDataNeighborhoods(data:Data) -> [Neighborhood] {
        var neighborhoods = [Neighborhood]()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let _json = json["neighborhoods"] as? [[String:AnyObject]] {
                let decoder = JSONDecoder()
                for jsonGroup in _json {
                    if let dataGroup = try? JSONSerialization.data(withJSONObject: jsonGroup) {
                        let group = try decoder.decode(Neighborhood.self, from:dataGroup)
                        neighborhoods.append(group)
                    }
                }
            }
        }
        catch {
            Logger.print("Error parsing Groups \(error)")
        }
        return neighborhoods
    }
    
    static func parseDataNeighborhood(data:Data) -> Neighborhood {
        var group = Neighborhood()
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] , let jsonGroup = json["neighborhood"] as? [String:AnyObject] {
                let decoder = JSONDecoder()
                if let dataGroup = try? JSONSerialization.data(withJSONObject: jsonGroup) {
                    group = try decoder.decode(Neighborhood.self, from:dataGroup)
                }
            }
        }
        catch {
            Logger.print("Error parsing group \(error)")
        }
        return group
    }
}
