//
//  UserService.swift
//  entourage
//
//  Created by Jerome on 12/01/2022.
//

import Foundation
import SimpleKeychain

struct UserService {
    
    //MARK: - Update User
    static func updateUser(user:User?, isOnboarding:Bool = true, completion: @escaping (_ user:User?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token, let user = user  else { completion(nil,nil)
            return
        }
        let endpoint = String.init(format: kAPIUpdateUser, token)
        
        let parameters = isOnboarding ? ["user" : user.dictionaryForWS()] : ["user" : user.dictionaryUserUpdateForWS()]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update user \(parameters)")
        
        Logger.print("Json Patch user")
        
        NetworkManager.sharedInstance.requestPatch(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post Login: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update user - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let userParsed = self.parsingDataUser(data: data).user
            
            DispatchQueue.main.async { completion(userParsed,nil) }
        }
    }
    
    static func updateUserPassword(pwd:String, completion: @escaping (_ user:User?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else { completion(nil,nil)
            return
        }
        let endpoint = String.init(format: kAPIUpdateUser, token)
        
        let parameters = ["user" : ["sms_code":pwd]]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update user pwd \(parameters)")
        
        NetworkManager.sharedInstance.requestPatch(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response  Patch userpwd: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error  Patch userpwd - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            A0SimpleKeychain().setString(pwd, forKey: kKeychainPassword)
            let userParsed = self.parsingDataUser(data: data).user
            
            DispatchQueue.main.async { completion(userParsed,nil) }
        }
    }
    
    //MARK: - Update User Address
    static func updateUserAddressWith(placeId:String, isSecondaryAddress:Bool, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = isSecondaryAddress ? kAPIUpdateAddressSecondary : kAPIUpdateAddressPrimary
        endpoint = String.init(format: endpoint, token)
        
        
        let parameters = [kWSKeyAddress : [kWSKeyGooglePlaceId: placeId]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update address placeId \(parameters)")
    
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post update User: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update address with placeid - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            let newUser = self.parsingDataUser(data: data).user
            Logger.print("***** update place id user: \(newUser?.addressPrimary?.displayAddress)")
            if newUser?.uuid != nil && newUser?.uuid?.count ?? 0 > 0 {
                UserDefaults.updateCurrentUser(newUser: newUser!)
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func updateUserAddressWith(name:String,latitude:Double,longitude:Double, isSecondaryAddress:Bool, completion: @escaping ( _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = isSecondaryAddress ? kAPIUpdateAddressSecondary : kAPIUpdateAddressPrimary
        endpoint = String.init(format: endpoint, token)
        
        
        let parameters = [kWSKeyAddress : [kWSKeyPlaceName: name,kWSKeyPlaceLatitude: latitude, kWSKeyPlaceLongitude:longitude]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update address name \(parameters)")
    
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post update User: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update address with name - \(error)")
                DispatchQueue.main.async { completion( error) }
                return
            }
            
            let newUser = self.parsingDataUser(data: data).user
            if newUser?.uuid != nil && newUser?.uuid?.count ?? 0 > 0 {
                UserDefaults.updateCurrentUser(newUser: newUser!)
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func deleteUserSecondAddress(completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUpdateAddressSecondary
        endpoint = String.init(format: endpoint, token)
    
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response Post update User: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error delete 2nd Address : \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            var currentUser = UserDefaults.currentUser
            currentUser?.addressSecondary = nil
            UserDefaults.currentUser = currentUser
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    //MARK: - Updates infos for user -
    
    static func updateUserAssociationInfo(association:Partner,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUpdateUserPartner
        endpoint = String.init(format: endpoint, token)
        
        var parameters:[String:Any] = ["token" : token]
        
        if association.aid ?? 0 > 0 {
            parameters["partner_id"] = association.aid!
        }
        if association.isCreation ?? false {
            parameters["new_partner_name"] = association.name
        }
        parameters["postal_code"] = association.postalCode
        parameters["partner_role_title"] = association.userRoleTitle
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update user partner \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post update User partner: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update User partner - \(error)")
                DispatchQueue.main.async { completion( error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func updateUserPartnerFollow(partnerId:Int,isFollowing:Bool,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUpdateAccountPartner
        endpoint = String.init(format: endpoint, token)
        
        let isFollowStr = isFollowing ? "true" : "false"
        
        let parameters:[String:Any] = ["following": ["partner_id":partnerId,"active":isFollowStr]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update user partner follow \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post update User partner: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update User partner - \(error)")
                DispatchQueue.main.async { completion( error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func updateUserInterests(interests:[String],completion: @escaping (_ user:User?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUpdateUser
        endpoint = String.init(format: endpoint, token)
        
        var parameters:[String:Any] = ["token" : token]
        parameters["user"] = ["interests" : interests]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        NetworkManager.sharedInstance.requestPatch(endPoint: endpoint, headers: nil, body: bodyData) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update User interests - \(error)")
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let userParsed = self.parsingDataUser(data: data).user
            
            DispatchQueue.main.async { completion(userParsed,nil) }
        }
    }
    
    static func getDetailsForUser(userId:String, completion: @escaping (_ user:User?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetDetailUser
        endpoint = String.init(format: endpoint,userId, token)
        
        Logger.print("***** get details user : \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update User interests - \(error)")
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let userParsed = self.parsingDataUser(data: data).user
            
            DispatchQueue.main.async { completion(userParsed,nil) }
        }
    }
    
    static func deleteUserAccount(completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIDeleteUser
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response Delete User : \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Delete User - \(error)")
                DispatchQueue.main.async { completion( error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func reportUser(userId:String, tags:[String], message:String? ,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIReportUser
        endpoint = String.init(format: endpoint,userId, token)
        
        let _msg:String = message != nil ? message! : ""
        let parameters:[String:Any] = ["user_report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post report User : \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report User - \(error)")
                DispatchQueue.main.async { completion( error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func getUnreadCountForUser(completion: @escaping (_ unreadCount:Int?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUnreadCount
        endpoint = String.init(format: endpoint, token)
        
        Logger.print("***** get kAPIUnreadCount : \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error kAPIUnreadCount - \(error)")
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let unreadCount = self.parsingUnreadCount(data: data)
            
            DispatchQueue.main.async { completion(unreadCount,nil) }
        }
    }
    
    static func parsingUnreadCount(data:Data) -> (Int) {
        var unreadCount = 0
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                if let _jsonUser = json["user"] as? [String:AnyObject], let dataUser = try? JSONSerialization.data(withJSONObject: _jsonUser) {
                    unreadCount = _jsonUser["unread_count"] as! Int
                }
            }
        }
        catch {
            Logger.print("Error parsing \(error)")
        }
        return (unreadCount)
    }
    
    //MARK: - Parsing -
    static func parsingDataUser(data:Data) -> (user:User?,isFirstLogin:Bool) {
        var user:User? = nil
        var isFirstLogin = false
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                let decoder = JSONDecoder()
                
                if let _jsonUser = json["user"] as? [String:AnyObject], let dataUser = try? JSONSerialization.data(withJSONObject: _jsonUser) {
                    user = try decoder.decode(User.self, from: dataUser)
                }
                isFirstLogin = json["first_sign_in"] as? Bool ?? false
            }
        }
        catch {
            Logger.print("Error parsing \(error)")
        }
        return (user,isFirstLogin)
    }
}


