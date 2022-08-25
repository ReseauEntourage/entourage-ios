//
//  MessagingService.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//

import Foundation

struct MessagingService:ParsingDataCodable {
    
    static func getAllConversations(currentPage:Int, per:Int, completion: @escaping (_ actions:[Conversation]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        var endpoint = kAPIConversationGetAllConversations
        
        endpoint = String.init(format: endpoint, token, currentPage, per)
        
        Logger.print("***** getAll messages : \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let messages:[Conversation]? = self.parseDatas(data: data, key: "conversations")
            DispatchQueue.main.async { completion(messages, nil) }
        }
    }
    
    static func getMessagesFor(conversationId:Int,currentPage:Int, per:Int, completion: @escaping (_ messages:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetConversationDetailMessages
        endpoint = String.init(format: endpoint,"\(conversationId)", token, currentPage, per)
        
        Logger.print("***** url get messages conversation : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get messages conversation  : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let messages:[PostMessage]? = self.parseDatas(data: data,key: "chat_messages")
            DispatchQueue.main.async { completion(messages,nil) }
        }
    }
    
    static func postCommentFor(conversationId:Int, message:String, completion: @escaping (_ messages:PostMessage?,_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIPostConversationMessage
        endpoint = String.init(format: endpoint, "\(conversationId)", token)

        let parameters = ["chat_message" : ["content":message]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed send Post message \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,error) }
                return
            }
            let message:PostMessage? = self.parseData(data: data, key: "chat_message")
            DispatchQueue.main.async { completion(message,nil) }
        }
    }
    
    static func createOrGetConversation(userId:String, completion: @escaping (_ conversation:Conversation?,_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIConversationPostCreateConversation
        endpoint = String.init(format: endpoint, token)

        let parameters = ["conversation" : ["user_id":userId]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed send create conversation \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,error) }
                return
            }
            let conversation:Conversation? = self.parseData(data: data, key: "conversation")
            DispatchQueue.main.async { completion(conversation,nil) }
        }
    }
}
