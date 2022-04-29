//
//  NeighborhoodService.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation

struct NeighborhoodService:ParsingDataCodable {
    
    static func getAllNeighborhoods( completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINeighborhoods
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group:[Neighborhood]? = self.parseDatas(data: data,key: "neighborhoods")
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    static func getNeighborhoodImages( completion: @escaping (_ images:[NeighborhoodImage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetneighborhoodImages
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let images:[NeighborhoodImage]? = self.parseDatas(data: data,key: "neighborhood_images")
            
            DispatchQueue.main.async { completion(images,nil) }
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
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    static func getSuggestNeighborhoods(currentPage:Int, per:Int, completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetSuggestNeighborhoods
        endpoint = String.init(format: endpoint, token, currentPage, per)
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    static func getNeighborhoodsForUserId(_ userId:String, currentPage:Int, per:Int, completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetMyNeighborhoods
        endpoint = String.init(format: endpoint, userId, token, currentPage, per)
        
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    
    static func getSearchNeighborhoods(text:String, completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPISearchNeighborhoods
        endpoint = String.init(format: endpoint, token, text)
        
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    fileprivate static func getNeighborhoodsWithEndpoint(_ endpoint: String, _ completion: @escaping ([Neighborhood]?, EntourageNetworkError?) -> Void) {
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group:[Neighborhood]? = self.parseDatas(data: data,key: "neighborhoods")
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
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
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
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    
    
    
    
}
