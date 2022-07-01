//
//  EventService.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import Foundation


struct EventService:ParsingDataCodable {
    
    static func getEventImages( completion: @escaping (_ eventsImages:[EventImage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventImages
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let eventImages:[EventImage]? = self.parseDatas(data: data, key: "entourage_images")
            DispatchQueue.main.async { completion(eventImages,nil) }
        }
    }
    
    static func getEventWithId(_ eventId:Int, completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventDetail
        endpoint = String.init(format: endpoint, eventId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data, key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func createEvent(event:Event ,completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventCreate
        endpoint = String.init(format: endpoint, token)
        
        let parameters = ["outing" : event.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed post event \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func updateEvent(event:EventEditing ,completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventEdit
        endpoint = String.init(format: endpoint,event.uid, token)
        
        let parameters = ["outing" : event.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed Put event \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Put event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Put event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func getAllEventsForUser(userId:Int, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventGetAllForUser
        endpoint = String.init(format: endpoint, "\(userId)", token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
}
