//
//  AuthService.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation
import SimpleKeychain
import CoreLocation


struct AuthService: ParsingDataCodable {
    //MARK: - Create user account -
    
    static func createAccountWith(user: User, completion: @escaping (_ phone: String?, _ error: EntourageNetworkError?) -> Void) {

        func nonEmpty(_ s: String?) -> String? {
            guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
            return t
        }
        func mapGender(_ g: String?) -> String? {
            guard let g = nonEmpty(g) else { return nil }
            switch g.lowercased() {
            case "homme", "male":   return "male"
            case "femme", "female": return "female"
            case "non binaire", "non-binaire", "non_binary", "autre", "other", "secret", "non renseigné", "non renseigne":
                return "secret"
            default:
                return nil // inconnu → on n’envoie pas
            }
        }

        // Champs obligatoires
        var userParameters: [String: Any] = [
            "phone":      user.phone ?? "",
            "first_name": user.firstname,
            "last_name":  user.lastname
        ]

        // Optionnels — n’ajouter la clé que si présent
        if let email = nonEmpty(user.email) {
            userParameters["email"] = email
        }
        if let hasConsent = user.hasConsent {
            userParameters["newsletter_subscription"] = hasConsent
        }
        if let g = mapGender(user.gender) {
            userParameters["gender"] = g
        }
        if let birth = nonEmpty(user.birthdate) {
            userParameters["birthdate"] = birth
        }
        if let source = nonEmpty(user.discoverySource) {
            userParameters["discovery_source"] = source
        }
        if let company = nonEmpty(user.company) {
            userParameters["sf_entreprise_id"] = company
        }
        if let event = nonEmpty(user.event) {
            userParameters["sf_campaign_id"] = event
        }

        let parameters: [String: Any] = ["user": userParameters]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        Logger.print("[AuthService] Datas passed \(parameters)")

        NetworkManager.sharedInstance.requestPost(endPoint: kAPICreateAccount, headers: nil, body: bodyData) { data, resp, error in
            Logger.print("[NetworkManager] ***** return resp post : \((resp as? HTTPURLResponse)?.statusCode ?? -1)")
            Logger.print("[AuthService] Response Post update User: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")

            if let data = data, let s = String(data: data, encoding: .utf8) {
                Logger.print("[AuthService] Create user response body: \(s)")
            }

            guard let data = data, error == nil, let http = resp as? HTTPURLResponse, http.statusCode < 300 else {
                Logger.print("[AuthService] Response error update User: ", error?.message)
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let userLight: [String: String]? = self.parseData(data: data, key: "user")
            let phone: String? = userLight?["phone"]
            DispatchQueue.main.async { completion(phone, nil) }
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


// MARK: - Onboarding zone (distance + adresse primaire)

extension AuthService {

    /// Met à jour le rayon de déplacement (travel_distance) via kAPIUpdateUser
    static func updateTravelDistance(_ distanceKm: Int,
                                     completion: @escaping (EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {
            completion(EntourageNetworkError())
            return
        }

        let endpoint = String(format: kAPIUpdateUser, token)

        let userParameters: [String: Any] = [
            "travel_distance": distanceKm
        ]

        let parameters: [String: Any] = ["user": userParameters]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        Logger.print("[AuthService] updateTravelDistance params: \(parameters)")

        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { data, resp, error in
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
            Logger.print("[AuthService] updateTravelDistance status: \(status)")

            if let data = data, let s = String(data: data, encoding: .utf8) {
                Logger.print("[AuthService] updateTravelDistance body: \(s)")
            }

            guard error == nil, let http = resp as? HTTPURLResponse, http.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }

            DispatchQueue.main.async { completion(nil) }
        }
    }

    /// Met à jour l'adresse primaire (users/me/addresses/1) :
    /// - si googlePlaceId non nul -> google_place_id
    /// - sinon latitude / longitude / place_name
    static func updatePrimaryAddress(
        googlePlaceId: String?,
        coordinate: CLLocationCoordinate2D?,
        label: String?,
        completion: @escaping (EntourageNetworkError?) -> Void
    ) {
        let tag = "[debug address]"

        guard let token = UserDefaults.token else {
            Logger.print("\(tag) ❌ missing token")
            completion(EntourageNetworkError())
            return
        }

        var endpoint = kAPIUpdateAddressPrimary
        endpoint = String(format: endpoint, token)

        var addressParams: [String: Any] = [:]

        if let placeId = googlePlaceId,
           !placeId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            addressParams["google_place_id"] = placeId
        } else if let coord = coordinate {
            addressParams["latitude"] = coord.latitude
            addressParams["longitude"] = coord.longitude
            if let label = label,
               !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                addressParams["place_name"] = label
            }
        } else {
            Logger.print("\(tag) ❌ no address data to send")
            completion(EntourageNetworkError())
            return
        }

        let parameters: [String: Any] = ["address": addressParams]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

        // -------- REQUEST LOG --------
        Logger.print("\(tag) ▶️ REQUEST")
        Logger.print("\(tag) URL: \(endpoint)")
        Logger.print("\(tag) METHOD: PUT")

        if let json = String(data: bodyData, encoding: .utf8) {
            Logger.print("\(tag) BODY: \(json)")
        } else {
            Logger.print("\(tag) BODY: <unreadable>")
        }

        NetworkManager.sharedInstance.requestPost(
            endPoint: endpoint,
            headers: nil,
            body: bodyData
        ) { data, resp, error in

            let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? -1

            // -------- RESPONSE LOG --------
            Logger.print("\(tag) ◀️ RESPONSE")
            Logger.print("\(tag) STATUS CODE: \(statusCode)")

            if let data = data, let body = String(data: data, encoding: .utf8) {
                Logger.print("\(tag) RESPONSE BODY: \(body)")
            } else {
                Logger.print("\(tag) RESPONSE BODY: <empty>")
            }

            if let error = error {
                Logger.print("\(tag) ERROR OBJECT: \(error)")
                Logger.print("\(tag) ERROR MESSAGE: \(error.message ?? "nil")")
            } else {
                Logger.print("\(tag) ERROR OBJECT: nil")
            }

            guard error == nil, statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }

            DispatchQueue.main.async { completion(nil) }
        }
    }


}

private func logRequest(tag: String,
                               method: String,
                               endpoint: String,
                               headers: [String: String]?,
                               body: Data?) {
    Logger.print("[\(tag)] \(method) \(endpoint)")
    if let headers = headers, !headers.isEmpty {
        Logger.print("[\(tag)] headers: \(headers)")
    } else {
        Logger.print("[\(tag)] headers: nil")
    }
    if let body = body {
        if let obj = try? JSONSerialization.jsonObject(with: body, options: []),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
           let s = String(data: pretty, encoding: .utf8) {
            Logger.print("[\(tag)] body:\n\(s)")
        } else if let s = String(data: body, encoding: .utf8) {
            Logger.print("[\(tag)] body(raw):\n\(s)")
        } else {
            Logger.print("[\(tag)] body: <\(body.count) bytes>")
        }
    } else {
        Logger.print("[\(tag)] body: nil")
    }
}

private func logResponse(tag: String,
                                resp: URLResponse?,
                                data: Data?,
                                error: EntourageNetworkError?) {
    let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
    Logger.print("[\(tag)] status: \(status)")
    if let data = data, let s = String(data: data, encoding: .utf8) {
        Logger.print("[\(tag)] response body:\n\(s)")
    }
    if let error = error {
        Logger.print("[\(tag)] error: \(String(describing: error.message))")
    } else {
        Logger.print("[\(tag)] error: nil")
    }
}
