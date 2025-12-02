//
//  AssociationService.swift
//  entourage
//
//  Created by Jerome on 17/01/2022.
//

import Foundation

struct AssociationService: ParsingDataCodable {

    static func getAllAssociations(completion: @escaping (_ associations: [Partner]?, _ error: EntourageNetworkError?) -> Void) {

        guard let token = UserDefaults.token else { return }

        var endpoint = kAPIGetAllAssociations
        endpoint = String(format: endpoint, token)

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

    static func getPartnerDetail(id: Int,
                                 completion: @escaping (_ association: Partner?, _ error: EntourageNetworkError?) -> Void) {

        guard let token = UserDefaults.token else { return }

        var endpoint = kAPIGetDetailAssociation
        endpoint = String(format: endpoint, id, token)

        Logger.print("***** url get detail asso : \(endpoint)")

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

    static func createAssociation(name: String,
                                  completion: @escaping (_ association: Partner?, _ error: EntourageNetworkError?) -> Void) {

        guard let token = UserDefaults.token else {
            completion(nil, nil)
            return
        }

        var endpoint = kAPICreateAssociation
        endpoint = String(format: endpoint, token)

        let partnerPayload: [String: Any] = [
            "name": name,
            "description": name
        ]

        let params: [String: Any] = [
            "partner": partnerPayload
        ]

        let bodyData = try? JSONSerialization.data(withJSONObject: params, options: [])

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
}
