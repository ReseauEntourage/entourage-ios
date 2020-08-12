//
//  OTPictureUploadS3Service.swift
//  entourage
//
//  Created by Jr on 30/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import Foundation

struct OTPictureUploadS3Service {
    
    //First step Prepare
    static func prepareUploadWith(image:UIImage, completion: @escaping (_ result: Bool)->()) {
        
        OTAuthService.prepareUploadPhoto(success: { (infos) in
            guard let _presigneUrl = infos?["presigned_url"] as? String, let _avatarKey = infos?["avatar_key"] as? String else {
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
            
        }) { (error) in
            Logger.print("Error prepare upload : \(String(describing: error?.localizedDescription))")
            completion(false)
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
                let statusCode = (response as! HTTPURLResponse).statusCode
                Logger.print("URL Session Task Succeeded: HTTP \(statusCode)")
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
        let _currentUser = UserDefaults.standard.currentUser
        _currentUser?.avatarKey = avatarKey
        OTAuthService().updateUserInformation(with: _currentUser, success: { (newUser) in
            newUser?.phone = _currentUser?.phone
            UserDefaults.standard.currentUser = newUser
            completion(true)
        }) { (error) in
            completion(false)
        }
    }
}
