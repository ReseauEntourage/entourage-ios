//
//  PictureUploadS3Service.swift
//  entourage
//
//  Created by Jr on 30/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import Foundation

struct PictureUploadS3Service {
    
    //First step Prepare
    static func prepareUploadWith(image:UIImage, completion: @escaping (_ result: Bool)->()) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = API_URL_USER_PREPARE_AVATAR_UPLOAD
        endpoint = String.init(format: endpoint, token)
        
        AuthService.prepareUploadPhotoS3(endpoint:endpoint) { json, error in
            guard let _presigneUrl = json?["presigned_url"] as? String, let _avatarKey = json?["avatar_key"] as? String else {
                completion(false)
                return
            }
            
            uploadtoS3(urlS3: _presigneUrl, avatar_key: _avatarKey
                , image: image, completion: {isOk in
                    if isOk {
                        updateUserWithAvatarKey(_avatarKey, completion: {isOk in
                            completion(isOk)
                        })
                    }
                    else {
                        completion(false)
                    }
            })
        }
    }
    
    //2nd step upload to Amazon
    static func uploadtoS3(urlS3:String, avatar_key:String, image:UIImage,completion: @escaping (_ result: Bool)->()) {
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
            if (error == nil) {
                completion(true)
            }
            else {
                Logger.print("URL Session Task Failed: %@", error!.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    //3nd step update user for avatarKey
    static func updateUserWithAvatarKey(_ avatarKey:String, completion: @escaping (_ result: Bool)->()) {
        var _currentUser = UserDefaults.currentUser
        _currentUser?.avatarKey = avatarKey
        UserService.updateUser(user: _currentUser) { user, error in
            if let user = user {
                var newUser = user
                newUser.phone = _currentUser?.phone
                UserDefaults.currentUser = newUser
                completion(true)
                return
            }
            completion(false)
        }
    }
}
