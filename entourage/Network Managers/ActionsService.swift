//
//  ActionsService.swift
//  entourage
//
//  Created by Jerome on 22/07/2022.
//

import Foundation


struct ActionsService:ParsingDataCodable {
    
    
    static func createAction(isContrib:Bool, action:Action, completion: @escaping (_ action:Action?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isContrib ? kAPIContribCreate : kAPISolicitationCreate
        endpoint = String.init(format: endpoint, token)
        
        let parameters = isContrib ? ["contribution" : action.dictionaryForWS()] : ["solicitation" : action.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed post event \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post action: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post action - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let key = isContrib ? "contribution" : "solicitation"
            let action:Action? = self.parseData(data: data,key: key)
            Logger.print("***** return create action : \(action)")
            DispatchQueue.main.async { completion(action, nil) }
        }
    }
    
    static func updateAction(isContrib:Bool, action:Action, completion: @escaping (_ action:Action?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isContrib ? kAPIContribUpdate : kAPISolicitationUpdate
        endpoint = String.init(format: endpoint, action.id, token)
        
        let parameters = isContrib ? ["contribution" : action.dictionaryForWS()] : ["solicitation" : action.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed put event \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response put action: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error put action - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let key = isContrib ? "contribution" : "solicitation"
            let action:Action? = self.parseData(data: data,key: key)
            DispatchQueue.main.async { completion(action, nil) }
        }
    }
    
    static func getAllActions(isContrib:Bool,currentPage:Int, per:Int, completion: @escaping (_ actions:[Action]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        var endpoint:String
        if isContrib {
            endpoint = kAPIActionGetAllContribs
        }
        else {
            endpoint = kAPIActionGetAllSolicitations
        }
        endpoint = String.init(format: endpoint, token, currentPage, per)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let actions:[Action]? = self.parseDatas(data: data, key: isContrib ? "contributions" : "solicitations")
            DispatchQueue.main.async { completion(actions, nil) }
        }
    }
    
    static func getAllMyActions(currentPage:Int, per:Int, completion: @escaping (_ actions:[Action]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        let endpoint = String.init(format: kAPIActionGetAllForMe, token, currentPage, per)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let actions:[Action]? = self.parseDatas(data: data, key: "actions")
            DispatchQueue.main.async { completion(actions, nil) }
        }
    }
}
