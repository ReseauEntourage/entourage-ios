//
//  MessagingService.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//

import Foundation

struct MessagingService:ParsingDataCodable {
    
    static func getAllMessages(currentPage:Int, per:Int, completion: @escaping (_ actions:[MessagingMessage]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        var endpoint = kAPIMessagingGetAllMessages
        
        endpoint = String.init(format: endpoint, token, currentPage, per)
        
        Logger.print("***** getAll messages : \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let messages:[MessagingMessage]? = self.parseDatas(data: data, key: "conversations")
            DispatchQueue.main.async { completion(messages, nil) }
        }
    }
}
