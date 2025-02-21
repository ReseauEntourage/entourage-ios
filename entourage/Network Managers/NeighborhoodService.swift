//
//  NeighborhoodService.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation

struct NeighborhoodService:ParsingDataCodable {
    
    static func getAllNeighborhoods( completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINeighborhoods
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group:[Neighborhood]? = self.parseDatas(data: data,key: "neighborhoods")
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    // MARK: - Get Default Neighborhood
    static func getDefaultGroup(completion: @escaping (_ group: Neighborhood?, _ error: EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPIGetDefaultNeighborhoods
        endpoint = String(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let group: Neighborhood? = self.parseData(data: data, key: "neighborhood")
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    
    static func getNeighborhoodImages( completion: @escaping (_ images:[NeighborhoodImage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetneighborhoodImages
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let images:[NeighborhoodImage]? = self.parseDatas(data: data,key: "neighborhood_images")
            
            DispatchQueue.main.async { completion(images,nil) }
        }
    }
    
    static func getNeighborhoodDetail(id:String, completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetDetailNeighborhood
        endpoint = String.init(format: endpoint,"\(id)", token)
        
        Logger.print("***** url get detail group : \(endpoint)")
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    static func getSuggestNeighborhoods(currentPage:Int, per:Int, completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetSuggestNeighborhoods
        endpoint = String.init(format: endpoint, token, currentPage, per)
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    static func getSuggestFilteredNeighborhoods(currentPage:Int, per:Int,radius:Float ,latitude:Float ,longitude:Float ,selectedItem:[String],  completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var stringifiedItems = ""
        if selectedItem.count != 0 {
            for itemSelected in selectedItem {
                stringifiedItems += itemSelected + ","
            }
            if stringifiedItems.last == "," {
                stringifiedItems.removeLast()
            }
        }
        var endpoint = kAPIGetSuggestFilteredNeighborhoods
        endpoint = String.init(format: endpoint, token, currentPage, per, radius, latitude,longitude,stringifiedItems)
        if stringifiedItems == "" {
            endpoint = kAPIGetSuggestFilteredNoInterestsNeighborhoods
            endpoint = String.init(format: endpoint, token, currentPage, per, radius, latitude,longitude)
        }
        
        print("neighborhood endpoint", endpoint)
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    static func getNeighborhoodsForUserId(_ userId:String, currentPage:Int, per:Int, completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetMyNeighborhoods
        endpoint = String.init(format: endpoint, userId, token, currentPage, per)
        
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    
    static func getSearchNeighborhoods(text:String, completion: @escaping (_ groups:[Neighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPISearchNeighborhoods
        endpoint = String.init(format: endpoint, token, text)
        
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
    fileprivate static func getNeighborhoodsWithEndpoint(_ endpoint: String, _ completion: @escaping ([Neighborhood]?, EntourageNetworkError?) -> Void) {
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let group:[Neighborhood]? = self.parseDatas(data: data,key: "neighborhoods")
            DispatchQueue.main.async { completion(group,nil) }
        }
    }
    
    
    static func getNeighborhoodUsers(neighborhoodId:Int, completion: @escaping (_ users:[UserLightNeighborhood]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetNeighborhoodUsers
        endpoint = String.init(format: endpoint,"\(neighborhoodId)", token)
        
        Logger.print("***** url get group users : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get group users : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            Logger.print("***** return get group users : \(data)")
            let users:[UserLightNeighborhood]? = self.parseDatas(data: data,key: "users")
            DispatchQueue.main.async { completion(users,nil) }
        }
    }
    
    static func getNeighborhoodUsersWithQuery(neighborhoodId: Int,
                                              query: String,
                                              completion: @escaping ([UserLightNeighborhood]?, EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else { return }
        
        // On construit l’endpoint en injectant l’id, le token et la query
        var endpoint = kAPIGetNeighborhoodUsersQuery
        endpoint = String(format: endpoint, "\(neighborhoodId)", token, query)
        
        Logger.print("***** url get group users with query : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get group users with query : \(String(describing: error))")
            
            // Vérifications d’usage
            guard let data = data,
                  error == nil,
                  let httpResponse = resp as? HTTPURLResponse,
                  httpResponse.statusCode < 300
            else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            // On parse le tableau de "users" depuis le JSON
            let users: [UserLightNeighborhood]? = self.parseDatas(data: data, key: "users")
            
            DispatchQueue.main.async {
                completion(users, nil)
            }
        }
    }

    
    static func getNeighborhoodPostsPaging(id:Int, currentPage:Int, per:Int, completion: @escaping (_ post:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetNeighborhoodPostsMessage
        endpoint = String.init(format: endpoint,"\(id)", token,currentPage,per)
        
        Logger.print("***** url get post message paging : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let posts:[PostMessage]? = self.parseDatas(data: data,key: "chat_messages")
            DispatchQueue.main.async { completion(posts,nil) }
        }
    }
    
    //MARK: - Create/update group -
    static func createNeighborhood(group:Neighborhood,completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPINeighborhoods
        endpoint = String.init(format: endpoint, token)

        let parameters = ["neighborhood" : group.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed post group \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post group: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post group - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    
    static func updateNeighborhood(group:Neighborhood,completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIUpdateNeighborhood
        endpoint = String.init(format: endpoint,"\(group.uid)", token)

        let parameters = ["neighborhood" : group.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed update group \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response update group: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update group - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    
    //MARK: - Join / Leave group
    
    
    static func joinNeighborhood(groupId:Int,completion: @escaping (_ user:MemberLight?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIJoinNeighborhood
        endpoint = String.init(format: endpoint,"\(groupId)", token)
        
        Logger.print("Endpoint passed update group \(endpoint)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response update group: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update group - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let user:MemberLight? = self.parseData(data: data,key: "user")
            DispatchQueue.main.async { completion(user, nil) }
        }
    }
    
    static func leaveNeighborhood(groupId:Int,userId:Int ,completion: @escaping (_ group:Neighborhood?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPILeaveNeighborhood
        endpoint = String.init(format: endpoint,"\(groupId)","\(userId)", token)
        
        Logger.print("Endpoint passed delete from group \(endpoint)")
                
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response delete from group: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update group - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let group:Neighborhood? = self.parseData(data: data,key: "neighborhood")
            DispatchQueue.main.async { completion(group, nil) }
        }
    }
    

    //MARK: - Report GRoup -
    static func reportNeighborhood(groupId:Int,message:String?,tags:[String], completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIReportNeighborhood
        endpoint = String.init(format: endpoint,"\(groupId)", token)
        
        let _msg:String = message != nil ? (message!.isEmpty ? "" : message!) : ""
        let parameters:[String:Any] = ["report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint reportGroup \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response reportGroup: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error reportGroup - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func reportNeighborhoodPost(groupId:Int,postId:Int,message:String?,tags:[String], isPost:Bool, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isPost ? kAPIReportPostNeighborhood : kAPIReportPostCommentNeighborhood
        endpoint = String.init(format: endpoint,"\(groupId)","\(postId)", token)
        
        let _msg:String = message != nil ? (message!.isEmpty ? "" : message!) : ""
        let parameters:[String:Any] = ["report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint report Group post \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response report Group post: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report Group post - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    //MARK: - Create Post (chat_message)
    
    static func createPostMessage(groupId:Int,message:String?, urlImage:String? = nil ,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIPostNeighborhoodPostMessage
        endpoint = String.init(format: endpoint, "\(groupId)", token)

        var content = [String:String]()
       
        if let message = message {
            content["content"] = message
        }
        
        if let urlImage = urlImage {
            content["image_url"] = urlImage
        }
        
        let parameters = ["chat_message" : content]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post group Post : \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post group Post - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func getDetailPostMessage(neighborhoodId:Int, parentPostId:Int, completion: @escaping (_ message:PostMessage?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetNeighborhoodPostMessage
        endpoint = String.init(format: endpoint,"\(neighborhoodId)","\(parentPostId)", token)
        
        Logger.print("***** url eho get PostMessage : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let message:PostMessage? = self.parseData(data: data,key: "chat_message")
            DispatchQueue.main.async { completion(message,nil) }
        }
    }
    
    //MARK: DELETE POST
    static func deletePostMessage(groupId:Int,messageId:Int, urlImage:String? = nil ,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIDeleteNeigborhoodPostMessage
        endpoint = String.init(format: endpoint, groupId, messageId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in

            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error DELETE event DELETE - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    
    
    //MARK: - Comments for Post -
    //MARK:ID CAN BE HASHED
    static func getCommentsFor(neighborhoodId:Int, parentPostId:Int, completion: @escaping (_ messages:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetNeighborhoodMessages
        endpoint = String.init(format: endpoint,"\(neighborhoodId)","\(parentPostId)", token)
        
        Logger.print("***** url get messages group : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get messages group  : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let messages:[PostMessage]? = self.parseDatas(data: data,key: "chat_messages")
            DispatchQueue.main.async { completion(messages,nil) }
        }
    }
    
    static func postCommentFor(neighborhoodId:Int, parentPostId:Int, message:String, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIPostNeighborhoodPostMessage
        endpoint = String.init(format: endpoint, "\(neighborhoodId)", token)

        let contentStr = "content"
        
        let parameters = ["chat_message" : [contentStr:message,"parent_id":parentPostId]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed send comment group Post \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    //  REACTION CALL
    static func postReactionToGroupPost(groupId: Int, postId: Int, reactionWrapper: ReactionWrapper, completion: @escaping (EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIPostReactionGroupPost, groupId, postId, token)

        guard let bodyData = try? JSONEncoder().encode(reactionWrapper) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { _, resp, error in
            guard let response = resp as? HTTPURLResponse, response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }

//
//    static func getGroupPostReactionDetails(groupId: Int, postId: Int, completion: @escaping ([UserLightNeighborhood]?, EntourageNetworkError?) -> Void) {
//        guard let token = UserDefaults.token else {return}
//        let endpoint = String(format: kAPIGetDetailsReactionGroupPost, groupId, postId, token)
//        
//        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
//            guard let data = data, let response = resp as? HTTPURLResponse, response.statusCode < 300 else {
//                DispatchQueue.main.async { completion(nil, error) }
//                return
//            }
//            let details: [UserLightNeighborhood]? = self.parseData(data: data, key: "users")
//            DispatchQueue.main.async { completion(details, nil) }
//        }
//    }
    static func getPostReactionsDetails(groupId: Int, postId: Int, completion: @escaping (CompleteReactionsResponse?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = String(format: kAPIGetDetailsReactionGroupPost, groupId, postId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data, let response = resp as? HTTPURLResponse, response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) } // Adapte l'erreur selon ton modèle d'erreur
                return
            }
            
            do {
                // Utilisation directe de JSONDecoder pour décoder la réponse
                let decoder = JSONDecoder()
                // Assurez-vous que la structure de la réponse correspond à ce que JSONDecoder s'attend à décoder
                let details = try decoder.decode(CompleteReactionsResponse.self, from: data)
                DispatchQueue.main.async { completion(details, nil) }
            } catch {
                print("Erreur lors du décodage des données: \(error)")
                DispatchQueue.main.async { completion(nil, nil) }
            }
        }
    }


    

    static func deleteReactionToGroupPost(groupId: Int, postId: Int, completion: @escaping (EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIDeleteReactionGroupPost, groupId, postId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { _, resp, error in
            guard let response = resp as? HTTPURLResponse, response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func searchNeighborhoods(query: String, currentPage: Int, per: Int, completion: @escaping (_ groups: [Neighborhood]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPINeighborhoodsSearch
        endpoint = String(format: endpoint, token, currentPage, per, query)
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }

    static func searchMyNeighborhoods(userId: String, query: String, currentPage: Int, per: Int, completion: @escaping (_ groups: [Neighborhood]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPIGetMyNeighborhoodsSearch
        endpoint = String(format: endpoint, userId, token, currentPage, per, query)
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }


    static func getFilteredMyNeighborhoods(userId: String, currentPage: Int, per: Int, radius: Float, latitude: Float, longitude: Float, selectedItem: [String], completion: @escaping (_ groups: [Neighborhood]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var stringifiedItems = selectedItem.joined(separator: ",")
        var endpoint = String(format: kAPIGetMyFilteredNeighborhoods, userId, token, currentPage, per, radius, latitude, longitude, stringifiedItems)
        if stringifiedItems.isEmpty {
            endpoint = String(format: kAPIGetSuggestFilteredNoInterestsMyNeighborhoods,userId, token, currentPage, per, radius, latitude, longitude)
        }
        getNeighborhoodsWithEndpoint(endpoint, completion)
    }
    
}
