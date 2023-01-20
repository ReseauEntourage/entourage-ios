//
//  AuthService.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation
import SimpleKeychain

struct AuthService: ParsingDataCodable {
    //MARK: - Create user account -
    
    static func createAccountWith(user:User,completion: @escaping (_ phone:String?, _ error:EntourageNetworkError?) -> Void) {
        
        let parameters = ["user" : ["phone": user.phone , "first_name": user.firstname, "last_name": user.lastname]]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed \(parameters)")
        
        Logger.print("Json Post create user")
        
        NetworkManager.sharedInstance.requestPost(endPoint: kAPICreateAccount, headers: nil, body: bodyData) { data, resp, error in
            
            Logger.print("Response Post update User: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update address with placeid - \(String(describing: error))")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let userLight:[String:String]? = self.parseData(data: data, key: "user")
            let phone:String? = userLight?["phone"] as? String
            
            DispatchQueue.main.async { completion(phone,nil) }
        }
        
    }
    
    //MARK: - Login -
    static func postLogin(phone:String,password:String, completion: @escaping (_ user:User?, _ error:EntourageNetworkError?,_ isFirstLogin:Bool) -> Void) {
        
        let parameters = ["user" : ["phone": phone , "sms_code": password]]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed \(parameters)")
        
        Logger.print("Json Post login")
        
        NetworkManager.sharedInstance.requestPost(endPoint: kAPILogin, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post Login: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print(error as Any)
                DispatchQueue.main.async { completion(nil, error, false) }
                return
            }
            
            A0SimpleKeychain().setString(phone, forKey: kKeychainPhone)
            A0SimpleKeychain().setString(password, forKey: kKeychainPassword)
            
            let dataParsed = UserService.parsingDataUser(data: data)
            
            DispatchQueue.main.async { completion(dataParsed.user,nil,dataParsed.isFirstLogin) }
        }
    }
    
    static func regenerateSecretCode(phone:String,completion: @escaping ( _ error:EntourageNetworkError?) -> Void) {
        let paramPhone = ["phone": phone]
        let paramAction = ["action": "regenerate"]
        
        let parameters = ["user": paramPhone, "code":paramAction]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        Logger.print("Datas passed \(parameters)")
        
        NetworkManager.sharedInstance.requestPatch(endPoint: kAPIResendCode, headers: nil, body: bodyData) { (data, resp, error)  in
            Logger.print("***** return regencode \(String(describing: resp))")
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data)
                Logger.print("***** return regencode json ? \(json)")
            }
            DispatchQueue.main.async { completion(error) }
        }
    }
    
    // Use to send token to Back
    static func sendPushTokenToAppInfo(pushToken:String,notifStatus:String, completion: @escaping ( _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIAppInfoPushToken
        endpoint = String.init(format: endpoint, token)
        let deviceStr = ProcessInfo.processInfo.operatingSystemVersionString
        let version:String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let params = ["push_token": pushToken, "device_os":deviceStr, "version":version, "notifications_permissions":notifStatus]
        
        
        let parameters = ["application": params]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        Logger.print("Datas passed send push token \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { data, resp, error in
            completion(error)
        }
    }
    
    //For Amazon S3 upload photo
    static func prepareUploadPhotoS3(endpoint:String, completion: @escaping (_ json:[String:AnyObject]?, _ error:EntourageNetworkError?) -> Void) {
        let parameters = ["content_type":"image/jpeg"]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { data, resp, error in
            do {
                if let data = data, let json = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] {
                    completion(json,error)
                    return
                }
            }
            catch{}
            
            completion(nil,error)
        }
    }
}
