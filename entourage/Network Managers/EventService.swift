//
//  EventService.swift
//  entourage
//
//  Created by Jerome on 24/06/2022.
//

import Foundation


struct EventService:ParsingDataCodable {
    
    static func getEventImages( completion: @escaping (_ eventsImages:[EventImage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventImages
        endpoint = String.init(format: endpoint, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let eventImages:[EventImage]? = self.parseDatas(data: data, key: "entourage_images")
            DispatchQueue.main.async { completion(eventImages,nil) }
        }
    }
    
    static func getEventWithId(_ eventId:String, completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventDetail
        endpoint = String.init(format: endpoint, eventId, token)
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data, key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func createEvent(event:Event ,completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventCreate
        endpoint = String.init(format: endpoint, token)
        
        let parameters = ["outing" : event.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed post event \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Post event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func updateEvent(event:EventEditing, isWithRecurrency:Bool, completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isWithRecurrency ? kAPIEventEditWithRecurrency : kAPIEventEdit
        endpoint = String.init(format: endpoint,event.uid, token)
        
        let parameters = ["outing" : event.dictionaryForWS()]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed Put event \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Put event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Put event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func updateEventRecurrency(eventId:Int, recurrency:Int, completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventEdit
        endpoint = String.init(format: endpoint,eventId, token)
        
        let parameters = ["outing" : ["recurrency":recurrency]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed Put event recurrency \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Put event recurrency: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Put event recurrency - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func getAllEventsForUser(userId:Int? = nil,currentPage:Int, per:Int, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        
        var endpoint:String
        if let userId = userId {
            endpoint = kAPIEventGetAllForUser
            endpoint = String.init(format: endpoint, "\(userId)", token, currentPage, per)
        }
        else {
            endpoint = kAPIEventGetAllForMe
            endpoint = String.init(format: endpoint, token, currentPage, per)
        }

        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
    
    static func getAllEventsForNeighborhoodId(_ groupId:Int, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventGetAllForNeighborhood
        endpoint = String.init(format: endpoint, groupId, token)
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
    
    static func getAllEventsDiscover(currentPage:Int, per:Int, filters:String?, completion: @escaping (_ events:[Event]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventGetAllDiscover
        endpoint = String.init(format: endpoint, token, currentPage, per)
        if let filters = filters {
            endpoint = "\(endpoint)&\(filters)"
        }
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let events:[Event]? = self.parseDatas(data: data, key: "outings")
            DispatchQueue.main.async { completion(events, nil) }
        }
    }
    
    static func getSuggestFilteredEvents(currentPage: Int, per: Int, radius: Float, latitude: Float, longitude: Float, selectedItem: [String], completion: @escaping (_ events: [Event]?, _ error: EntourageNetworkError?) -> Void) {
            
            guard let token = UserDefaults.token else { return }
            var stringifiedItems = ""
            if selectedItem.count != 0 {
                for itemSelected in selectedItem {
                    stringifiedItems += itemSelected + ","
                }
                if stringifiedItems.last == "," {
                    stringifiedItems.removeLast()
                }
            }
            
            var endpoint: String
            if stringifiedItems.isEmpty {
                endpoint = kAPIEventGetAllFilteredDiscoverNoInterest
                endpoint = String.init(format: endpoint, token, currentPage, per, radius, latitude, longitude)
            } else {
                endpoint = kAPIEventGetAllFilteredDiscover
                endpoint = String.init(format: endpoint, token, currentPage, per, radius, latitude, longitude, stringifiedItems)
            }
            
            print("event endpoint", endpoint)
            getEventsWithEndpoint(endpoint, completion)
        }
        
        fileprivate static func getEventsWithEndpoint(_ endpoint: String, _ completion: @escaping ([Event]?, EntourageNetworkError?) -> Void) {
            NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
                guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                    DispatchQueue.main.async { completion(nil, error) }
                    return
                }
                
                let events: [Event]? = self.parseDatas(data: data, key: "outings")
                DispatchQueue.main.async { completion(events, nil) }
            }
        }

    
    static func getEventPostsPaging(id:Int, currentPage:Int, per:Int, completion: @escaping (_ post:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetEventPostsMessage
        endpoint = String.init(format: endpoint,"\(id)", token, currentPage, per)
        
        Logger.print("***** url get post event message paging : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            
            let posts:[PostMessage]? = self.parseDatas(data: data,key: "chat_messages")
            DispatchQueue.main.async { completion(posts,nil) }
        }
    }
    
    static func getEventUsersWithQuery(eventId: Int,
                                       query: String,
                                       completion: @escaping ([UserLightNeighborhood]?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        
        var endpoint = kAPIGetEventUsersQuery
        endpoint = String(format: endpoint, "\(eventId)", token, query)
        
        Logger.print("***** url get event users with query : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get event users with query : \(String(describing: error))")
            
            guard let data = data,
                  error == nil,
                  let httpResponse = resp as? HTTPURLResponse,
                  httpResponse.statusCode < 300
            else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let users: [UserLightNeighborhood]? = self.parseDatas(data: data, key: "users")
            DispatchQueue.main.async {
                completion(users, nil)
            }
        }
    }

    
    static func getEventUsers(
        eventId: Int,
        page: Int = 1,
        per: Int = 20,
        completion: @escaping (_ users: [UserLightNeighborhood]?, _ nextPage: Int?, _ error: EntourageNetworkError?) -> Void
    ) {
        guard let token = UserDefaults.token else { return }
        let endpoint = "\(String(format: kAPIGetEventUsers, "\(eventId)", token))&page=\(page)&per=\(per)"
        Logger.print("***** getEventUsers page \(page): \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            guard let data = data,
                  error == nil,
                  let http = resp as? HTTPURLResponse,
                  http.statusCode < 300
            else {
                DispatchQueue.main.async { completion(nil, nil, error) }
                return
            }
            let list: [UserLightNeighborhood]? = parseDatas(data: data, key: "users")
            let count = list?.count ?? 0
            let next = (count == per) ? page + 1 : nil
            DispatchQueue.main.async { completion(list, next, nil) }
        }
    }
    
    //MARK: - Join / Leave group
    
    static func joinEvent(eventId:Int,completion: @escaping (_ user:MemberLight?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIJoinEvent
        endpoint = String.init(format: endpoint,"\(eventId)", token)
        
        Logger.print("Endpoint passed update event \(endpoint)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response update event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let user:MemberLight? = self.parseData(data: data,key: "user")
            DispatchQueue.main.async { completion(user, nil) }
        }
    }
    
    static func joinEventAsOrganizer(eventId: Int, completion: @escaping (_ user: MemberLight?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPIJoinEvent
        endpoint = String(format: endpoint, "\(eventId)", token)
        
        Logger.print("Endpoint passed to join event as organizer \(endpoint)")
        
        // Créer le body avec le dictionnaire
        let body: [String: Any] = ["role": "organizer"]
        
        // Convertir le body en Data pour l'envoyer dans la requête
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            Logger.print("Failed to serialize JSON body")
            return
        }
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response for joining event as organizer: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error joining event as organizer - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let user: MemberLight? = self.parseData(data: data, key: "user")
            DispatchQueue.main.async { completion(user, nil) }
        }
    }

    
    static func leaveEvent(eventId:Int,userId:Int ,completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPILeaveEvent
        endpoint = String.init(format: endpoint,"\(eventId)","\(userId)", token)
        
        Logger.print("Endpoint passed delete from event \(endpoint)")
                
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response delete from event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error update event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    static func cancelEvent(eventId:Int, completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventCancel
        endpoint = String.init(format: endpoint,eventId, token)
        
        Logger.print("Endpoint passed cancel event \(endpoint)")
                
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            Logger.print("Response cancel event: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error cancel event - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    
    
    static func cancelEventWithRecurrency(eventId:Int, completion: @escaping (_ event:Event?, _ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIEventCancelWithRecurrency
        endpoint = String.init(format: endpoint,eventId, token)
        
        let parameters = ["outing" : ["status":"closed","recurrency":0]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed cancel event alls \(parameters)")
        
        NetworkManager.sharedInstance.requestPut(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response Put cancel event alls: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let data = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Put cancel event alls - \(error)")
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            let event:Event? = self.parseData(data: data,key: "outing")
            DispatchQueue.main.async { completion(event, nil) }
        }
    }
    //MARK: - Report Event + Post -
    static func reportEvent(eventId:Int,message:String?,tags:[String], completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIReportEvent
        endpoint = String.init(format: endpoint,"\(eventId)", token)
        
        let _msg:String = message != nil ? (message!.isEmpty ? "" : message!) : ""
        let parameters:[String:Any] = ["report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint reportEvent \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response reportEvent: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error reportEvent - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func reportEventPost(eventId:Int,postId:Int,message:String?,tags:[String], isPost:Bool, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = isPost ? kAPIReportPostEvent : kAPIReportPostCommentEvent
        endpoint = String.init(format: endpoint,"\(eventId)","\(postId)", token)
        
        let _msg:String = message != nil ? (message!.isEmpty ? "" : message!) : ""
        let parameters:[String:Any] = ["report":["message":_msg, "signals":tags]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Endpoint report Event post \(endpoint) -- params : \(parameters)")
                
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            Logger.print("Response report Event post: \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error report Event post - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    //MARK: - Create Post (chat_message)
    
    static func createPostMessage(eventId:Int,message:String?, urlImage:String? = nil ,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIPostOutingPostMessage
        endpoint = String.init(format: endpoint, "\(eventId)", token)

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
            Logger.print("Response Post event Post : \(String(describing: (resp as? HTTPURLResponse)?.statusCode)) -- \(String(describing: (resp as? HTTPURLResponse)))")
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error Post event Post - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    static func getDetailPostMessage(eventId:Int, parentPostId:Int, completion: @escaping (_ message:PostMessage?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetOutingPostMessage
        endpoint = String.init(format: endpoint,"\(eventId)","\(parentPostId)", token)
        
        Logger.print("***** url get PostMessage : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let message:PostMessage? = self.parseData(data: data,key: "chat_message")
            DispatchQueue.main.async { completion(message,nil) }
        }
    }
    
    //MARK DELETE EVENT POST
    static func deletePostMessage(eventId:Int,messageId:Int, urlImage:String? = nil ,completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIDeleteEventPostMessage
        endpoint = String.init(format: endpoint, eventId, messageId, token)
        
        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                Logger.print("***** error delete event delete - \(error)")
                DispatchQueue.main.async { completion(error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    
    
    //MARK: - Comments for Post -
    
    static func getCommentsFor(eventId:String, parentPostId:String, completion: @escaping (_ messages:[PostMessage]?, _ error:EntourageNetworkError?) -> Void) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIGetOutingMessages
        endpoint = String.init(format: endpoint,"\(eventId)","\(parentPostId)", token)
        
        Logger.print("***** url get messages event : \(endpoint)")
        
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, resp, error in
            
            Logger.print("***** return get messages event  : \(error)")
            
            guard let data = data,error == nil,let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil,  error) }
                return
            }
            let messages:[PostMessage]? = self.parseDatas(data: data,key: "chat_messages")
            DispatchQueue.main.async { completion(messages,nil) }
        }
    }
    
    static func postCommentFor(eventId:Int, parentPostId:Int, message:String, completion: @escaping (_ error:EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        var endpoint = kAPIPostOutingPostMessage
        endpoint = String.init(format: endpoint, "\(eventId)", token)

        let contentStr = "content"
        
        let parameters = ["chat_message" : [contentStr:message,"parent_id":parentPostId]]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        Logger.print("Datas passed send comment event Post \(parameters)")
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { (data, resp, error) in
            guard let _ = data, error == nil, let _response = resp as? HTTPURLResponse, _response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            
            DispatchQueue.main.async { completion(nil) }
        }
    }
    
    //reactions :
    static func postReactionToEventPost(eventId: Int, postId: Int, reactionWrapper: ReactionWrapper, completion: @escaping (EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIPostReactionEventPost, eventId, postId, token)

        guard let bodyData = try? JSONEncoder().encode(reactionWrapper) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: bodyData) { _, resp, error in
            guard let response = resp as? HTTPURLResponse, response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }

    
    static func deleteReactionToEventPost(eventId: Int, postId: Int, completion: @escaping (EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else {return}
        let endpoint = String(format: kAPIDeleteReactionEventPost, eventId, postId, token)

        NetworkManager.sharedInstance.requestDelete(endPoint: endpoint, headers: nil, body: nil) { _, resp, error in
            guard let response = resp as? HTTPURLResponse, response.statusCode < 300 else {
                DispatchQueue.main.async { completion(error) }
                return
            }
            DispatchQueue.main.async { completion(nil) }
        }
    }

    
//    static func getEventPostReactionDetails(eventId: Int, postId: Int, completion: @escaping ([UserLightNeighborhood]?, EntourageNetworkError?) -> Void) {
//        guard let token = UserDefaults.token else {return}
//        let endpoint = String(format: kAPIGetDetailsReactionEventPost, eventId, postId, token)
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
    static func getEventPostReactionDetails(eventId: Int, postId: Int, completion: @escaping (CompleteReactionsResponse?, EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = String(format: kAPIGetDetailsReactionEventPost, eventId, postId, token)
        
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
    
    static func confirmParticipation(eventId: Int, completion: @escaping (_ success: Bool, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = String(format: kAPIConfirmParticipation, "\(eventId)", token)
        
        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { (data, resp, error) in
            guard error == nil, let response = resp as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(false, error) }
                return
            }
            
            if response.statusCode < 300 {
                DispatchQueue.main.async { completion(true, nil) }
            } else {
                DispatchQueue.main.async { completion(false, nil) }
            }
        }
    }
    static func getFilteredMyEvents(userId: Int, currentPage: Int, per: Int, radius: Float, latitude: Float, longitude: Float, selectedItem: [String], completion: @escaping (_ events: [Event]?, _ error: EntourageNetworkError?) -> Void) {
            guard let token = UserDefaults.token else { return }
            let stringifiedItems = selectedItem.joined(separator: ",")
            var endpoint = String(format: kAPIGetMyFilteredOutings, String(userId), token, currentPage, per, radius, latitude, longitude, stringifiedItems)
            if stringifiedItems.isEmpty {
                endpoint = String(format: kAPIEventGetAllForUser,String(userId), token, currentPage, per)
            }
            getEventsWithEndpoint(endpoint, completion)
        }

    static func searchEvents(query: String, currentPage: Int, per: Int, completion: @escaping (_ events: [Event]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = String(format: kAPISearchEvents, token, currentPage, per, query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        getEventsWithEndpoint(endpoint, completion)
    }

    static func searchMyEvents(userId:String, query: String, currentPage: Int, per: Int, completion: @escaping (_ events: [Event]?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        let endpoint = String(format: kAPISearchMyEvents, userId, token, currentPage, per, query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        getEventsWithEndpoint(endpoint, completion)
    }

    static func getSuggestedSmallTalkEvent(completion: @escaping (Event?) -> Void) {
        let endpoint = "outings/smalltalk?token=\(UserDefaults.token ?? "")"
        NetworkManager.sharedInstance.requestGet(endPoint: endpoint, headers: nil, params: nil) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            let wrapper = try? JSONDecoder().decode(OutingWrapper.self, from: data)
            completion(wrapper?.outing)
        }
    }
    // MARK: - Admin actions on members (participate / cancel / photo acceptance)

    static func participateForUser(eventId: Int,
                                   userId: Int,
                                   completion: @escaping (_ user: MemberLight?, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPIParticipateForUser
        endpoint = String(format: endpoint, "\(eventId)", "\(userId)", token)

        Logger.print("Endpoint participateForUser: \(endpoint)")

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { data, resp, error in
            let status = (resp as? HTTPURLResponse)?.statusCode
            Logger.print("Response participateForUser: \(String(describing: status))")

            guard let data = data,
                  error == nil,
                  let http = resp as? HTTPURLResponse,
                  http.statusCode < 300 else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }

            // Android renvoie EntourageUserResponse{ user: ... }
            // On reste cohérent iOS: on parse "user" -> MemberLight
            let user: MemberLight? = self.parseData(data: data, key: "user")
            DispatchQueue.main.async { completion(user, nil) }
        }
    }

    static func acceptPhotoForUser(eventId: Int,
                                   userId: Int,
                                   completion: @escaping (_ success: Bool, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPIAcceptPhotoForUser
        endpoint = String(format: endpoint, "\(eventId)", "\(userId)", token)

        Logger.print("Endpoint acceptPhotoForUser: \(endpoint)")

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { _, resp, error in
            let http = resp as? HTTPURLResponse
            let ok = (error == nil) && ((http?.statusCode ?? 500) < 300)
            Logger.print("Response acceptPhotoForUser: \(String(describing: http?.statusCode))")
            DispatchQueue.main.async { completion(ok, ok ? nil : error) }
        }
    }
    static func cancelPhotoForUser(eventId: Int,
                                   userId: Int,
                                   completion: @escaping (_ success: Bool, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPICancelPhotoForUser
        endpoint = String(format: endpoint, "\(eventId)", "\(userId)", token)

        Logger.print("Endpoint acceptPhotoForUser: \(endpoint)")

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { _, resp, error in
            let http = resp as? HTTPURLResponse
            let ok = (error == nil) && ((http?.statusCode ?? 500) < 300)
            Logger.print("Response acceptPhotoForUser: \(String(describing: http?.statusCode))")
            DispatchQueue.main.async { completion(ok, ok ? nil : error) }
        }
    }

    static func cancelParticipationForUser(eventId: Int,
                                           userId: Int,
                                           completion: @escaping (_ success: Bool, _ error: EntourageNetworkError?) -> Void) {
        guard let token = UserDefaults.token else { return }
        var endpoint = kAPICancelParticipationForUser
        endpoint = String(format: endpoint, "\(eventId)", "\(userId)", token)

        Logger.print("Endpoint cancelParticipationForUser: \(endpoint)")

        NetworkManager.sharedInstance.requestPost(endPoint: endpoint, headers: nil, body: nil) { _, resp, error in
            let http = resp as? HTTPURLResponse
            let ok = (error == nil) && ((http?.statusCode ?? 500) < 300)
            Logger.print("Response cancelParticipationForUser: \(String(describing: http?.statusCode))")
            DispatchQueue.main.async { completion(ok, ok ? nil : error) }
        }
    }

}
