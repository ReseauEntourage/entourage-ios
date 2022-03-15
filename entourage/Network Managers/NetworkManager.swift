//
//  NetworkManager.swift
//  entourage
//
//  Created by Jerome on 12/01/2022.
//

import Foundation

enum Result <T> {
    case Success(T)
    case Error(Error?)
}

class NetworkManager {
    static let sharedInstance = NetworkManager()
    
    private init() {
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    }
    
    private var sessionConfig = URLSessionConfiguration.default
    private var session:URLSession
    
    private func envConfig() -> EnvironmentConfigurationManager {
        let envConfigManager = EnvironmentConfigurationManager.sharedInstance
        return envConfigManager
    }
    
    func getBaseUrl() -> String {
        let envConfig = envConfig()
        return envConfig.configCopy?[UserStorageKey.APIHostURL] as? String ?? ""
    }
    private func getApiKey() -> String {
        let envConfig = envConfig()
        return envConfig.APIKey as String
    }
    
    private func addRequiereHeaders(urlRequest: inout URLRequest) {
        urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(getApiKey(), forHTTPHeaderField: "X-API-KEY")
        urlRequest.addValue("iOS", forHTTPHeaderField: "X-Platform")
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            urlRequest.addValue(version, forHTTPHeaderField: "X-App-Version")
        }
    }
    
    func requestGet(endPoint:String,headers:[String:String]?, params:[String:String]?, completionHandler: @escaping (_ data:Data?, _ resp:URLResponse?, _ error:EntourageNetworkError?) -> Void) {
        let urlStr = getBaseUrl() + endPoint
        guard var url = URL(string: urlStr) else {return}
        
        if let params = params {
          url =  url.appendingQueryParameters(params)
        }
        
        var urlRequest = URLRequest.init(url: url)
        urlRequest.timeoutInterval = 120
        urlRequest.httpMethod = "GET"
        
        if let _headers = headers {
            for (key,value) in _headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        addRequiereHeaders(urlRequest: &urlRequest)
        
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                Logger.print("***** return resp GET : \(resp.statusCode)")
                if resp.statusCode < 300 {
                    completionHandler(data,response,nil)
                }
                else if resp.statusCode == 401 {
                    //TODO: Call Ask new token ?
                    completionHandler(nil,resp,nil)
                }
                else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject]  {
                        let entourageError = EntourageNetworkError(json: json["error"] as! [String:AnyObject])
                        Logger.print("***** return resp GET error : \(json) - entourage Error : \(entourageError)")
                        completionHandler(nil,response,entourageError)
                        return
                    }
                    
                    completionHandler(nil,response,nil)
                }
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func requestPost(endPoint:String,headers:[String:String]?, body:Data?, completionHandler: @escaping (_ data:Data?, _ resp:URLResponse?, _ error:EntourageNetworkError?) -> Void) {
        let url = getBaseUrl() + endPoint
        
        guard let url = URL(string: url) else {
            completionHandler(nil,nil,nil)
            return
        }
        
        var urlRequest = URLRequest.init(url: url)
        urlRequest.timeoutInterval = 40
        urlRequest.httpMethod = "POST"
        
        if let _headers = headers {
            for (key,value) in _headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        addRequiereHeaders(urlRequest: &urlRequest)
        
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            
            if let resp = response as? HTTPURLResponse {
                Logger.print("***** return resp post : \(resp.statusCode)")
                if resp.statusCode < 300 {
                    completionHandler(data,response,nil)
                    return
                }
                else if resp.statusCode == 401 && endPoint != kAPILogin {
                    NotificationCenter.default.post(name: NSNotification.Name(notificationLoginError), object: nil)
                    return
                }
                else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject]  {
                        let entourageError = EntourageNetworkError(json: json["error"] as! [String:AnyObject])
                        Logger.print("***** return resp post error : \(json) - entourage Error : \(entourageError)")
                        completionHandler(nil,response,entourageError)
                        return
                    }
                }
            }
            
            if let error = error {
                Logger.print("***** error Post real ici \(error.localizedDescription)")
                var errorEntourage = EntourageNetworkError()
                errorEntourage.error = error
                completionHandler(nil,response,errorEntourage)
                return
            }
            completionHandler(nil,response,nil)
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func requestPatch(endPoint:String,headers:[String:String]?, body:Data?, completionHandler: @escaping (_ data:Data?, _ resp:URLResponse?, _ error:EntourageNetworkError?) -> Void) {
        let url = getBaseUrl() + endPoint
        
        guard let url = URL(string: url) else {
            completionHandler(nil,nil,nil)
            return
        }
        
        var urlRequest = URLRequest.init(url: url)
        urlRequest.timeoutInterval = 10
        urlRequest.httpMethod = "PATCH"
        
        if let _headers = headers {
            for (key,value) in _headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        addRequiereHeaders(urlRequest: &urlRequest)
        
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                Logger.print("***** return resp PATCH : \(resp.statusCode)")
                if resp.statusCode < 300 {
                    completionHandler(data,response,nil)
                }
                else if resp.statusCode == 401 {
                    //TODO: Call Ask new token ?
                }
                else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject]  {
                        let entourageError = EntourageNetworkError(json: json["error"] as! [String:AnyObject])
                        Logger.print("***** return resp PATCH error : \(json) - entourage Error : \(entourageError)")
                        completionHandler(nil,response,entourageError)
                        return
                    }
                    
                    completionHandler(nil,response,nil)
                }
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func requestDelete(endPoint:String,headers:[String:String]?, body:Data?, completionHandler: @escaping (_ data:Data?, _ resp:URLResponse?, _ error:EntourageNetworkError?) -> Void) {
        let url = getBaseUrl() + endPoint
        
        guard let url = URL(string: url) else {
            completionHandler(nil,nil,nil)
            return
        }
        
        var urlRequest = URLRequest.init(url: url)
        urlRequest.timeoutInterval = 10
        urlRequest.httpMethod = "DELETE"
        
        if let _headers = headers {
            for (key,value) in _headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        addRequiereHeaders(urlRequest: &urlRequest)
        
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                Logger.print("***** return resp DELETE : \(resp.statusCode)")
                if resp.statusCode < 300 {
                    completionHandler(data,response,nil)
                }
                else if resp.statusCode == 401 {
                    //TODO: Call Ask new token ?
                }
                else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject]  {
                        let entourageError = EntourageNetworkError(json: json["error"] as! [String:AnyObject])
                        Logger.print("***** return resp DELETE error : \(json) - entourage Error : \(entourageError)")
                        completionHandler(nil,response,entourageError)
                        return
                    }
                    
                    completionHandler(nil,response,nil)
                }
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func requestPut(endPoint:String,headers:[String:String]?, body:Data?, completionHandler: @escaping (_ data:Data?, _ resp:URLResponse?, _ error:EntourageNetworkError?) -> Void) {
        let url = getBaseUrl() + endPoint
        
        guard let url = URL(string: url) else {
            completionHandler(nil,nil,nil)
            return
        }
        
        var urlRequest = URLRequest.init(url: url)
        urlRequest.timeoutInterval = 10
        urlRequest.httpMethod = "PUT"
        
        if let _headers = headers {
            for (key,value) in _headers {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        addRequiereHeaders(urlRequest: &urlRequest)
        
        session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                Logger.print("***** return resp PUT : \(resp.statusCode)")
                if resp.statusCode < 300 {
                    completionHandler(data,response,nil)
                }
                else if resp.statusCode == 401 {
                    //TODO: Call Ask new token ?
                }
                else {
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String:AnyObject]  {
                        let entourageError = EntourageNetworkError(json: json["error"] as! [String:AnyObject])
                        Logger.print("***** return resp PUT error : \(json) - entourage Error : \(entourageError)")
                        completionHandler(nil,response,entourageError)
                        return
                    }
                    
                    completionHandler(nil,response,nil)
                }
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    static func getUserToken() -> [String:String]? {
        if let user = UserDefaults.currentUser {
            return ["token":user.token]
        }
        return nil
    }
}


struct EntourageNetworkError {
    var code:String
    var message:String
    var error:Error?
    
    init(json:[String:AnyObject]) {
        code = json["code"] as! String
        message = json["message"] as! String
        error = nil
    }
    init() {
        code = ""
        message = ""
        error = nil
    }
}

