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
    
    static func getAllEventsForUser(userId:Int? = nil,currentPage:Int, per:Int, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        var endpoint:String
        if let userId = userId {
            endpoint = kAPIEventGetAllForUser
            endpoint = String.init(format: endpoint, "\(userId)", token, currentPage, per)
        }
        else {
            endpoint = kAPIEventGetAllForMe
            endpoint = String.init(format: endpoint, token, currentPage, per)
        }
       
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
    
    static func getAllEventsForNeighborhoodId(_ groupId:Int, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventGetAllForNeighborhood
        endpoint = String.init(format: endpoint, groupId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
    
    static func getAllEventsDiscover(currentPage:Int, per:Int, filters:String?, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventGetAllDiscover
        endpoint = String.init(format: endpoint, token, currentPage, per)
        if let filters = filters {
            endpoint = "\(endpoint)&\(filters)"
        }
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
    
    static func getEventPostsPaging(id:Int, currentPage:Int, per:Int, completion: @escaping (_ post:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetEventPostsMessage
        endpoint = String.init(format: endpoint,"\(id)", token, currentPage, per)
        
        Logger.print("***** url get post event message paging : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let posts:[PostMessage]? = self.parseDatas(data: data,key: "chat_messages")
            DispatchQueue.main.async { completion(posts,nil) }
        }
    }
    
    static func getEventUsers(eventId:Int, completion: @escaping (_ users:[UserLightNeighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetEventUsers
        endpoint = String.init(format: endpoint,"\(eventId)", token)
        
        Logger.print("***** url get group event users : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get group event users : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            Logger.print("***** return get group event users : \(data)")
            let users:[UserLightNeighborhood]? = self.parseDatas(data: data,key: "users")
            DispatchQueue.main.async { completion(users,nil) }
        }
    }
    
    //MARK: - Join / Leave group
    
    static func joinEvent(eventId:Int,completion: @escaping (_ user:MemberLight?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIJoinEvent
        endpoint = String.init(format: endpoint,"\(eventId)", token)
        
        Logger.print("Endpoint passed update event \(endpoint)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response update event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let user:MemberLight? = self.parseData(data: data,key: "user")
            DispatchQueue.main.async { completion(user, nil) }
        }
    }
    
    static func leaveEvent(eventId:Int,userId:Int ,completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPILeaveEvent
        endpoint = String.init(format: endpoint,"\(eventId)","\(userId)", token)
        
        Logger.print("Endpoint passed delete from event \(endpoint)")
                
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response delete from event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
}
