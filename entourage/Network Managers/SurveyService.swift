//
//  SurveyService.swift
//  entourage
//
//  Created by Clement entourage on 15/03/2024.
//

import Foundation

struct SurveyService {

    // Post Survey Response for a Group
    static func postSurveyResponseGroup(groupId: Int, postId: Int, responses: [Bool], completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIPostSurveyResponseGroup, groupId, postId, token)
        let surveyResponseRequest = SurveyResponsesWrapper(responses: responses)
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: surveyResponseRequest.toJSONData()) { data, resp, error in
            let isSuccess = data != nil && error == nil && (resp as? HTTPURLResponse)!.statusCode < 300
            DispatchQueue.main.async { completion(isSuccess) }
            
        }
    }
    static func postSurveyResponseEvent(eventId: Int, postId: Int, responses: [Bool], completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIPostSurveyResponseEvent, eventId, postId, token)
        let surveyResponseRequest = SurveyResponsesWrapper(responses: responses)
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: surveyResponseRequest.toJSONData()) { data, resp, error in
            let isSuccess = data != nil && error == nil && (resp as? HTTPURLResponse)!.statusCode < 300
            DispatchQueue.main.async { completion(isSuccess) }
            
        }
    }
    
    // Get Survey Responses for a Group
    static func getSurveyResponsesForGroup(groupId: Int, postId: Int, completion: @escaping (_ surveyResponsesList: SurveyResponsesListWrapper?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIGetSurveyResponsesForGroup, groupId, postId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let surveyResponsesList: SurveyResponsesListWrapper? = self.parseData(data: data)
            DispatchQueue.main.async { completion(surveyResponsesList, nil) }
        }
    }
    
    static func deleteSurveyResponseForGroup(groupId: Int, postId: Int, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let token = UserDefaults.token else {
            completion(false)
            return
        }
        let endpoint = String(format: kAPIDeleteSurveyResponseForGroup, groupId, postId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            let isSuccess = data != nil && error == nil && (resp as? HTTPURLResponse)!.statusCode < 300
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    static func createSurveyInGroup(groupId: Int, content: String, choices: [String], multiple: Bool, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let token = UserDefaults.token else {
            completion(false)
            return
        }
        
        let surveyAttributes = SurveyAttributes(choices: choices, multiple: multiple)
        let chatMessageSurvey = ChatMessageSurvey(content: content, surveyAttributes: surveyAttributes)
        
        guard let requestBody = try? JSONEncoder().encode(chatMessageSurvey) else {
            completion(false)
            return
        }
        
        let endpoint = String(format: kAPICreateSurveyInGroup, groupId, token)
        let headers = ["Content-Type": "application/json"]
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: headers, body: requestBody) { data, resp, error in
            let isSuccess = data != nil && error == nil && (resp as? HTTPURLResponse)!.statusCode < 300
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }

    static func getSurveyResponsesForEvent(eventId: Int, postId: Int, completion: @escaping (_ surveyResponsesList: SurveyResponsesListWrapper?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {
            completion(nil, nil) // Assurez-vous d'avoir un cas d'erreur pour cela
            return
        }
        let endpoint = String(format: kAPIGetSurveyResponsesForEvent, eventId, postId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data, error == nil, let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error ?? nil) } // Utilisez un cas d'erreur approprié
                return
            }
            
            do {
                let surveyResponsesList = try JSONDecoder().decode(SurveyResponsesListWrapper.self, from: data)
                DispatchQueue.main.async { completion(surveyResponsesList, nil) }
            } catch {
                DispatchQueue.main.async { completion(nil, nil) } // Assurez-vous d'avoir un cas d'erreur pour cela
            }
        }
    }

    static func deleteSurveyResponseForEvent(eventId: Int, postId: Int, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let token = UserDefaults.token else {
            completion(false)
            return
        }
        let endpoint = String(format: kAPIDeleteSurveyResponseForEvent, eventId, postId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            let isSuccess = data != nil && error == nil && (resp as? HTTPURLResponse)!.statusCode < 300
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }

    static func createSurveyInEvent(eventId: Int, content: String, choices: [String], multiple: Bool, completion: @escaping (_ isSuccess: Bool) -> Void) {
        guard let token = UserDefaults.token else {
            completion(false)
            return
        }
        
        let surveyAttributes = SurveyAttributes(choices: choices, multiple: multiple)
        let chatMessageSurvey = ChatMessageSurvey(content: content, surveyAttributes: surveyAttributes)
        
        guard let requestBody = try? JSONEncoder().encode(chatMessageSurvey) else {
            completion(false)
            return
        }
        
        let endpoint = String(format: kAPICreateSurveyInEvent, eventId, token)
        let headers = ["Content-Type": "application/json"]
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: headers, body: requestBody) { data, resp, error in
            let isSuccess = data != nil && error == nil && (resp as? HTTPURLResponse)!.statusCode < 300
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }

    
    static func parseData<T: Decodable>(data: Data) -> T? {
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Model Extensions for JSON Conversion
extension SurveyResponsesWrapper {
    func toJSONData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
