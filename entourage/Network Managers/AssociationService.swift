//
//  AssociationService.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation

struct AssociationService: ParsingDataCodable {

    // MARK: - GET All Associations
    static func getAllAssociations(completion: @escaping (_ associations: [Partner]?, _ error: EntourageNetworkError?) -> Void) {

        guard let token = UserDefaults.token else { return }

        var endpoint = kAPIGetAllAssociations
        endpoint = String(format: endpoint, token)

        logCurl(endpoint: endpoint, method: "GET", body: nil)

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint,
                                                 headers: nil,
                                                 params: nil) { data, resp, error in

            guard let data = data,
                  error == nil,
                  let response = resp as? HTTPURLResponse,
                  response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let associations: [Partner]? = self.parseDatas(data: data, key: "partners")
            DispatchQueue.main.async { completion(associations, nil) }
        }
    }

    // MARK: - GET Detail
    static func getPartnerDetail(id: Int,
                                 completion: @escaping (_ association: Partner?, _ error: EntourageNetworkError?) -> Void) {

        guard let token = UserDefaults.token else { return }

        var endpoint = kAPIGetDetailAssociation
        endpoint = String(format: endpoint, id, token)

        logCurl(endpoint: endpoint, method: "GET", body: nil)

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint,
                                                 headers: nil,
                                                 params: nil) { data, resp, error in

            guard let data = data,
                  error == nil,
                  let response = resp as? HTTPURLResponse,
                  response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let association: Partner? = self.parseData(data: data, key: "partner")
            DispatchQueue.main.async { completion(association, nil) }
        }
    }

    // MARK: - JOIN Association
    static func joinAssociation(partnerId: Int,
                                postalCode: String? = nil,
                                userRoleTitle: String? = nil,
                                completion: @escaping (_ error: EntourageNetworkError?) -> Void) {

        guard let token = UserDefaults.token else {
            completion(nil)
            return
        }

        var endpoint = kAPIUpdateUserPartner
        endpoint = String(format: endpoint, token)

        var params: [String: Any] = [
            "partner_id": partnerId
        ]

        if let postalCode = postalCode, !postalCode.isEmpty {
            params["postal_code"] = postalCode
        }

        if let userRoleTitle = userRoleTitle, !userRoleTitle.isEmpty {
            params["partner_role_title"] = userRoleTitle
        }

        let bodyData = try? JSONSerialization.data(withJSONObject: params, options: [])

        logCurl(endpoint: endpoint, method: "POST", body: bodyData)

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint,
                                                  headers: nil,
                                                  body: bodyData) { data, resp, error in

            guard let _ = data,
                  error == nil,
                  let response = resp as? HTTPURLResponse,
                  response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }

            DispatchQueue.main.async { completion(nil) }
        }
    }

    // MARK: - CREATE Association
    static func createAssociation(
        name: String,
        address: String?,
        latitude: Double?,
        longitude: Double?,
        completion: @escaping (_ association: Partner?, _ error: EntourageNetworkError?) -> Void
    ) {
        guard let token = UserDefaults.token else {
            completion(nil, nil)
            return
        }

        var endpoint = kAPICreateAssociation
        endpoint = String(format: endpoint, token)

        var partnerPayload: [String: Any] = [
            "name": name,
            "description": name
        ]

        let trimmedAddress = (address ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAddress.isEmpty {
            partnerPayload["address"] = trimmedAddress
        }
        if let latitude = latitude {
            partnerPayload["latitude"] = latitude
        }
        if let longitude = longitude {
            partnerPayload["longitude"] = longitude
        }

        let params: [String: Any] = [
            "partner": partnerPayload
        ]

        let bodyData = try? JSONSerialization.data(withJSONObject: params, options: [])

        logCurl(endpoint: endpoint, method: "POST", body: bodyData)

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint,
                                                  headers: nil,
                                                  body: bodyData) { data, resp, error in

            guard let data = data,
                  error == nil,
                  let response = resp as? HTTPURLResponse,
                  response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let association: Partner? = self.parseData(data: data, key: "partner")
            DispatchQueue.main.async { completion(association, nil) }
        }
    }
    
    // MARK: - UPDATE Partner
    static func updatePartner(partnerId: Int,
                              data: [String: Any],
                              completion: @escaping (_ success: Bool, _ error: EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else { return }
        
        var endpoint = kAPIPartnerUpdate
        endpoint = String(format: endpoint, partnerId, token)
        
        // Wrapper "partner" requis par l'API Ruby
        let bodyParams: [String: Any] = ["partner": data]
        let bodyData = try? JSONSerialization.data(withJSONObject: bodyParams, options: [])
        
        logCurl(endpoint: endpoint, method: "PUT", body: bodyData)
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { data, resp, error in
            
            if let response = resp as? HTTPURLResponse, response.statusCode >= 400 {
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("🔥 API ERROR UPDATE RESPONSE: \(str)")
                }
            }
            
            guard let _ = data,
                  error == nil,
                  let response = resp as? HTTPURLResponse,
                  response.statusCode < 300 else {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            
            DispatchQueue.main.async { completion(true, nil) }
        }
    }
    
    // MARK: - GET Presigned URL
    static func getPresignedUploadUrl(contentType: String,
                                      completion: @escaping (_ uploadKey: String?, _ presignedUrl: String?, _ error: EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else { return }
        
        var endpoint = kAPIPartnerPresignedUpload
        endpoint = String(format: endpoint, token)
        
        let params: [String: Any] = ["content_type": contentType]
        let bodyData = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        logCurl(endpoint: endpoint, method: "POST", body: bodyData)
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { data, resp, error in
            
            guard let data = data,
                  error == nil,
                  let response = resp as? HTTPURLResponse,
                  response.statusCode < 300 else {
            
                if let data = data, let str = String(data: data, encoding: .utf8) {
                    print("🔥 ERREUR PRESIGNED URL RESPONSE: \(str)")
                }
                DispatchQueue.main.async { completion(nil, nil, error) }
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let key = json["upload_key"] as? String
                let url = json["presigned_url"] as? String
                DispatchQueue.main.async { completion(key, url, nil) }
            } else {
                DispatchQueue.main.async { completion(nil, nil, nil) }
            }
        }
    }
    
    // MARK: - UPLOAD to S3
    static func uploadImageToPresignedUrl(urlStr: String,
                                          data: Data,
                                          completion: @escaping (_ success: Bool) -> Void) {
        guard let url = URL(string: urlStr) else { completion(false); return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        
        print("\n---------- CURL S3 DEBUG ----------")
        print("curl -v -X PUT \"\(urlStr)\" -H \"Content-Type: image/jpeg\" --data-binary @image.jpg")
        print("-----------------------------------\n")
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async { completion(true) }
            } else {
                DispatchQueue.main.async { completion(false) }
            }
        }
        task.resume()
    }

    private static func logCurl(endpoint: String, method: String, body: Data?) {
        let baseUrl = "https://api-preprod.entourage.social/api/v1/"
        let urlStr = endpoint.hasPrefix("http") ? endpoint : baseUrl + endpoint
        
        var curlCommand = "curl -v -X \(method)"
        curlCommand += " \"\(urlStr)\""
        
        curlCommand += " -H \"Content-Type: application/json\""
        curlCommand += " -H \"Accept: application/json\""
        
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            let escapedBody = bodyString.replacingOccurrences(of: "\"", with: "\\\"")
            curlCommand += " -d \"\(escapedBody)\""
        }
        
        print("\n---------- CURL DEBUG ----------")
        print(curlCommand)
        print("--------------------------------\n")
    }
}
