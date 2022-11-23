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
    
    static func getResourceWithId(_ id:Int, completion: @escaping (_ resource:PedagogicResource?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIHomeGetResource
        endpoint = String.init(format: endpoint, id, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let resource:PedagogicResource? = self.parseData(data: data,key: "resource")
            DispatchQueue.main.async { completion(resource, nil) }
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
    
    static func markRecoWebUrlRead( webUrl:String, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIHomeWebRecoRead
        guard let _url = webUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed ) else {return}
        endpoint = String.init(format: endpoint,_url,token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    //Notifs  in app
    
    static func getNotificationsCount(completion: @escaping (_ count:Int?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINotifsGetCount
        endpoint = String.init(format: endpoint, token)
        
        Logger.print("***** url getNotificationsCount : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return getNotificationsCount  : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let count:Int? = self.parseSingleValueData(data: data,key: "count")
            DispatchQueue.main.async { completion(count,nil) }
        }
    }
    
    static func getNotifications(currentPage:Int, per:Int, completion: @escaping (_ notifs:[NotifInApp]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINotifsGetNotifs
        endpoint = String.init(format: endpoint, token, currentPage, per)
        
        Logger.print("***** url getNotifications : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return getNotifications  : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let notifs:[NotifInApp]? = self.parseDatas(data: data,key: "inapp_notifications")
            DispatchQueue.main.async { completion(notifs,nil) }
        }
    }
    
    static func markReadNotif( notifId:Int, completion: @escaping (_ notif:NotifInApp?,_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINotifsMarkRead
        endpoint = String.init(format: endpoint,notifId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,error) }
                return
            }
            
            let notif:NotifInApp? = self.parseData(data: data, key: "inapp_notification")
            
            DispatchQueue.main.async { completion(notif, nil) }
        }
    }
    
    static func getNotifsPermissions( completion: @escaping (_ notifPerms:NotifInAppPermission?,_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINotifsGetPermissions
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,error) }
                return
            }
            
            let notif:NotifInAppPermission? = self.parseData(data: data, key: "notification_permissions")
            
            DispatchQueue.main.async { completion(notif, nil) }
        }
    }
    
    static func updateNotifsPermissions(notifPerms:NotifInAppPermission, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINotifsPostPermissions
        endpoint = String.init(format: endpoint, token)
        
        let parameters:[String:Any] = ["notification_permissions" : notifPerms.getDatasForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint post update notifs perms \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response post update notifs perms: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("*****post update notifs perms - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
}
