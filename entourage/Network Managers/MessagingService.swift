//
//  MessagingService.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//

import Foundation

struct MessagingService:ParsingDataCodable {
    
    static func searchUsersInConversation(
        conversationId: String,
        query: String,
        page: Int,
        per: Int,
        completion: @escaping ([MemberLight]?, EntourageNetworkError?) -> Void
    ) {
        guard let token = UserDefaults.token else {
            completion(nil, nil)
            return
        }

        // On part de l'endpoint existant et on ajoute le paramètre `query`
        let baseEndpoint = String(format: kAPIConversationUsersList, conversationId, token)
        let endpoint = "\(baseEndpoint)&page=\(page)&per=\(per)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        Logger.print("***** search users in conversation: \(endpoint)")

        NetworkManager.sharedInstance.requestGet(
            endPoint: endpoint,
            headers: nil,
            params: nil
        ) { data, resp, error in
            guard let data = data, error == nil,
                  let httpResp = resp as? HTTPURLResponse, httpResp.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            let users: [MemberLight]? = self.parseDatas(data: data, key: "users")
            DispatchQueue.main.async { completion(users, nil) }
        }
    }


    
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
    
    static func getDetailConversation(conversationId:String, completion: @escaping (_ conversation:Conversation?, _ error:EntourageNetworkError?) -> Void) {
        
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
    
    static func getMessagesFor(conversationId:String,currentPage:Int, per:Int, completion: @escaping (_ messages:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        
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
    
    static func deletetCommentFor(chatMessageId:Int, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIChatMessageDelete
        endpoint = String.init(format: endpoint, chatMessageId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
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
    
    
    //Block / Unbloc User
    static func blockUser(userId:Int, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIBlockUser
        endpoint = String.init(format: endpoint, token)
        
        let parameters:[String:Any] = ["blocked_user_id":userId]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint report block user \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response report block user: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report block user - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func unblockUser(usersID:[Int], completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUnBlockUsers
        endpoint = String.init(format: endpoint, token)
                
        Logger.print("Endpoint report unblock user \(endpoint)")
        
        let parameters:[String:Any] = ["blocked_user_ids":usersID]
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
                
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response report unblock user: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report unblock user - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func getUsersBlocked(completion: @escaping (_ users:[UserBlocked]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetBlockedUsers
        endpoint = String.init(format: endpoint, token)
        
        Logger.print("Endpoint report get block users \(endpoint) ")
                
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { (data, resp, error) in
            Logger.print("Response report get block users: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error get report block users - \(error)")
                DispatchQueue.main.async { completion(nil,error) }
                return
            }
            let users:[UserBlocked]? = self.parseDatas(data: data, key: "user_blocked_users")
            
            DispatchQueue.main.async { completion(users, nil) }
        }
    }
    
    static func isUserBlocked(userId:Int,completion: @escaping (_ usersBlocked:UserBlocked?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetIsBlockedUser
        endpoint = String.init(format: endpoint, userId, token)
        
        Logger.print("Endpoint report get block user \(endpoint) ")
                
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { (data, resp, error) in
            Logger.print("Response report get block user: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error get report block user - \(error)")
                DispatchQueue.main.async { completion(nil,error) }
                return
            }
            
            let user:UserBlocked? = self.parseData(data: data, key: "user_blocked_user")
            DispatchQueue.main.async { completion(user, nil) }
        }
    }
    
    static func addUserToConversation(conversationId: String, completion: @escaping (_ success: Bool, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return completion(false, nil) }
        let endpoint = String(format: kAPIAddUserToConversation, conversationId, token)
        
        // Pour déboguer, logguons l'URL complète de la requête
        print("URL de la requête: \(endpoint)")

        // Supposons que votre body est vide ou ajustez selon votre API
        // Si vous devez envoyer un JSON vide, utilisez ceci :
        let bodyData = "{}".data(using: .utf8)!

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            if let error = error {
                print(" joinLogin Erreur lors de la requête: \(error)")
            }

            if let httpResponse = resp as? HTTPURLResponse {
                if httpResponse.statusCode < 300  {
                    DispatchQueue.main.async { completion(true, nil) }
                } else {
                    DispatchQueue.main.async { completion(false, nil) }
                }
            } else {
            }
        }
    }

    static func getOutingConversations(currentPage: Int, per: Int, completion: @escaping (_ conversations: [Conversation]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        
        let endpoint = String(format: kAPIConversationGetOutingConversations, token, currentPage, per)
        
        Logger.print("***** getAll outing messages : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let conversations: [Conversation]? = self.parseDatas(data: data, key: "conversations")
            DispatchQueue.main.async { completion(conversations, nil) }
        }
    }

    static func getPrivateConversations(currentPage: Int, per: Int, completion: @escaping (_ conversations: [Conversation]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        
        let endpoint = String(format: kAPIConversationGetPrivateConversations, token, currentPage, per)
        
        Logger.print("***** getAll private messages : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let conversations: [Conversation]? = self.parseDatas(data: data, key: "conversations")
            DispatchQueue.main.async { completion(conversations, nil) }
        }
    }
    
    static func getUsersForConversation(
        conversationId: Int,
        page: Int = 1,
        per: Int = 20,
        completion: @escaping ([MemberLight]?, Int?, EntourageNetworkError?) -> Void
    ) {
        guard let token = UserDefaults.token else { return }
        // on ajoute les params page & per après la constante de base
        let base = String(format: kAPIConversationUsersList, "\(conversationId)", token)
        let endpoint = "\(base)&page=\(page)&per=\(per)"
        
        Logger.print("***** get users for conversation page \(page): \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data, error == nil,
                  let httpResp = resp as? HTTPURLResponse, httpResp.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, nil, error) }
                return
            }
            let users: [MemberLight]? = self.parseDatas(data: data, key: "users")
            let count = users?.count ?? 0
            let nextPage: Int? = (count == per) ? page + 1 : nil
            DispatchQueue.main.async { completion(users, nextPage, nil) }
        }
    }
    
    // First step: Prepare the upload
       static func prepareUploadWith(conversationId: Int, image: UIImage, message: String?, completion: @escaping (_ result: Bool) -> Void) {
           guard let token = UserDefaults.token else {
               completion(false)
               return
           }

           let endpoint = String(format: API_URL_CONVERSATION_PREPARE_IMAGE_POST_UPLOAD, "\(conversationId)", token)

           AuthService.prepareUploadPhotoS3(endpoint: endpoint) { json, error in
               guard let presignedUrl = json?["presigned_url"] as? String,
                     let uploadKey = json?["upload_key"] as? String else {
                   completion(false)
                   return
               }

               self.uploadToS3(urlS3: presignedUrl, image: image) { isOk in
                   if isOk {
                       var textMessage = message
                       print("eho message ", message)
                       if ((message?.contains("messaging_message_placeholder_discut".localized )) != nil)  {
                           textMessage = " "
                       }
                       self.postWithImageAndText(imageKey: uploadKey, conversationId: conversationId, message: textMessage, completion: completion)
                   } else {
                       completion(false)
                   }
               }
           }
       }

       // Second step: Upload to Amazon S3
       private static func uploadToS3(urlS3: String, image: UIImage, completion: @escaping (_ result: Bool) -> Void) {
           guard let url = URL(string: urlS3), let data = image.jpegData(compressionQuality: 0.8) else {
               completion(false)
               return
           }

           let sessionConfig = URLSessionConfiguration.default
           let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

           var request = URLRequest(url: url)
           request.httpMethod = "PUT"
           request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")

           let task = session.uploadTask(with: request, from: data) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
               if error == nil {
                   completion(true)
               } else {
                   Logger.print("URL Session Task Failed: \(error!.localizedDescription)")
                   completion(false)
               }
           }

           task.resume()
           session.finishTasksAndInvalidate()
       }

       // Third step: Post the message with the image URL
       private static func postWithImageAndText(imageKey: String, conversationId: Int, message: String?, completion: @escaping (_ result: Bool) -> Void) {
           guard let token = UserDefaults.token else {
               completion(false)
               return
           }

           let endpoint = String(format: kAPIPostConversationMessage, "\(conversationId)", token)

           var chatMessage: [String: Any] = [:]
           if let message = message {
               chatMessage["content"] = message
               if message.contains("messaging_message_placeholder_discut".localized){
                   chatMessage["content"] = " "
               }
           }
           chatMessage["image_url"] = imageKey

           let parameters = ["chat_message": chatMessage]
           let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])

           NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { _, resp, error in
               if let error = error {
                   Logger.print("Error posting message: \(error)")
                   completion(false)
                   return
               }

               if let httpResponse = resp as? HTTPURLResponse, httpResponse.statusCode < 300 {
                   completion(true)
               } else {
                   completion(false)
               }
           }
       }
    
    static func getConversationMemberships(
            type: String?,
            page: Int,
            per: Int,
            completion: @escaping (_ memberships: [ConversationMembership]?, _ error: EntourageNetworkError?) -> Void
        ) {
            guard let token = UserDefaults.token else { return }

            // Construire la partie "&type=…" si besoin
            let typeQuery = (type != nil && !type!.isEmpty) ? "&type=\(type!)" : ""
            let endpoint = String(
                format: kAPIConversationMemberships,
                token,
                page,
                per,
                typeQuery
            )
            Logger.print("***** getConversationMemberships: \(endpoint)")

            NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
                guard let data = data,
                      error == nil,
                      let http = resp as? HTTPURLResponse, http.statusCode < 300 else {
                    DispatchQueue.main.async { completion(nil, error) }
                    return
                }

                do {
                    let wrapper = try JSONDecoder().decode(ConversationMembershipsWrapper.self, from: data)
                    DispatchQueue.main.async { completion(wrapper.memberships, nil) }
                } catch {
                    DispatchQueue.main.async {
                        print("error getting membership")
                    }
                }
            }
        }

}
