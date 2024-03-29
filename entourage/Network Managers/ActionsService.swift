//
//  ActionsService.swift
//  entourage
//
//  Created by Jerome on 22/07/2022.
//

import Foundation


struct ActionsService:ParsingDataCodable {
    
    fileprivate static let _contribution = "contribution"
    fileprivate static let _contributions = "contributions"
    fileprivate static let _solicitation = "solicitation"
    fileprivate static let _solicitations = "solicitations"
    
    static func createAction(isContrib:Bool, action:Action, completion: @escaping (_ action:Action?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isContrib ? kAPIContribCreate : kAPISolicitationCreate
        endpoint = String.init(format: endpoint, token)
        
        let parameters = isContrib ? [_contribution : action.dictionaryForWS()] : [_solicitation : action.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed post event \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post action: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post action - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let key = isContrib ? _contribution : _solicitation
            let action:Action? = self.parseData(data: data,key: key)
            Logger.print("***** return create action : \(action)")
            DispatchQueue.main.async { completion(action, nil) }
        }
    }
    
    static func updateAction(isContrib:Bool, action:Action, completion: @escaping (_ action:Action?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isContrib ? kAPIContribUpdate : kAPISolicitationUpdate
        endpoint = String.init(format: endpoint, action.id, token)
        
        let parameters = isContrib ? [_contribution : action.dictionaryForWS()] : [_solicitation : action.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed put event \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response put action: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error put action - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let key = isContrib ? _contribution : _solicitation
            let action:Action? = self.parseData(data: data,key: key)
            DispatchQueue.main.async { completion(action, nil) }
        }
    }
    
    static func cancelAction(isContrib:Bool, actionId:Int, isClosedOk:Bool, message:String?, completion: @escaping (_ action:Action?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isContrib ? kAPIContribUpdate : kAPISolicitationUpdate
        endpoint = String.init(format: endpoint, actionId, token)
        //TODO: a ajouter les 2 params
        
        var parameters: [String:Any] = ["outcome" : isClosedOk]
        if let message = message {
            parameters["close_message"] = message
        }
        
        let params = isContrib ? [_contribution : parameters] : [_solicitation : parameters]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: params, options: [])
        
        Logger.print("***** Params delete Action : \(params)")
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response delete action: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error delete action - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            let key = isContrib ? _contribution : _solicitation
            let action:Action? = self.parseData(data: data,key: key)
            DispatchQueue.main.async { completion(action, nil) }
        }
    }
    
    static func reportActionPost(isContrib:Bool, actionId:Int,message:String?,tags:[String], completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isContrib ? kAPIReportContrib : kAPIReportSolicitation
        endpoint = String.init(format: endpoint,"\(actionId)", token)
        
        let _msg:String = message != nil ? (message!.isEmpty ? "" : message!) : ""
        let parameters:[String:Any] = ["report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint report Action post \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response report Action post: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report Action post - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func getAllActions(isContrib:Bool,currentPage:Int, per:Int,filtersLocation:String?, filtersSections:String?, completion: @escaping (_ actions:[Action]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        var endpoint:String
        if isContrib {
            endpoint = kAPIActionGetAllContribs
        }
        else {
            endpoint = kAPIActionGetAllSolicitations
        }
        endpoint = String.init(format: endpoint, token, currentPage, per)
        
        if let filtersLocation = filtersLocation {
            endpoint = "\(endpoint)&\(filtersLocation)"
        }
        if let filtersSections = filtersSections {
            endpoint = "\(endpoint)&sections[]=\(filtersSections)"
        }
        
        Logger.print("***** getAll Actions : \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let actions:[Action]? = self.parseDatas(data: data, key: isContrib ? _contributions : _solicitations)
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
    
    static func getDetailAction(isContrib:Bool,actionId:String, completion: @escaping (_ action:Action?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint:String
        if isContrib {
            endpoint = kAPIGetContrib
        }
        else {
            endpoint = kAPIGetSolicitation
        }
        endpoint = String.init(format: endpoint, actionId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject]
                if let jsonSolicitation = json?["solicitation"] as? [String: AnyObject] {
                    let decoder = JSONDecoder()
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonSolicitation)
                    let solicitationResponse = try decoder.decode(Action.self, from: jsonData)
                    // Utilisez 'solicitationResponse' comme nécessaire
                }
            } catch {
                print("Erreur de décodage : \(error)")
            }

            let action:Action? = self.parseData(data: data, key: isContrib ? _contribution : _solicitation)
            DispatchQueue.main.async { completion(action, nil) }
        }
    }
}
