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
    
    static func getDetailConversation(conversationId:Int, completion: @escaping (_ conversation:Conversation?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIConversationGetDetailConversation
        endpoint = String.init(format: endpoint,"\(conversationId)", token)
        
        Logger.print("***** url get detail conversation : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get detail conversation  : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let conversation:Conversation? = self.parseData(data: data,key: "conversation")
            DispatchQueue.main.async { completion(conversation,nil) }
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
    
    static func reportConversation(conversationId:Int,message:String?,tags:[String], completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIConversationReportConversation
        endpoint = String.init(format: endpoint,"\(conversationId)", token)
        
        let _msg:String = message != nil ? (message!.isEmpty ? "" : message!) : ""
        let parameters:[String:Any] = ["report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint report conversation \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response report conversation: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report conversation - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    static func leaveConversation(conversationId:Int, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIConversationQuitConversation
        endpoint = String.init(format: endpoint,"\(conversationId)", token)
        
        Logger.print("Endpoint leave conversation \(endpoint)")
                
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response leave conversation: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error leave conversation - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    
}
