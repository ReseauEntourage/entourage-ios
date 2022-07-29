//
//  EventUploadPictureService.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import Foundation

struct EventUploadPictureService {
    
    //First step Prepare
    static func prepareUploadWith(eventId:Int, image:UIImage, message:String? , completion: @escaping (_ result: Bool)->()) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = API_URL_EVENT_PREPARE_IMAGE_POST_UPLOAD
        endpoint = String.init(format: endpoint,"\(eventId)", token)
        
        AuthService.prepareUploadPhotoS3(endpoint:endpoint) { json, error in
            guard let _presigneUrl = json?["presigned_url"] as? String, let _uploadKey = json?["upload_key"] as? String else {
                completion(false)
                return
            }
            
            uploadtoS3(urlS3: _presigneUrl, image: image, completion: {isOk in
                if isOk {
                    postWithImageAndText(imageKey: _uploadKey, eventId: eventId, message: message, completion: {isOk in
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
    static func uploadtoS3(urlS3:String, image:UIImage,completion: @escaping (_ result: Bool)->()) {
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
    static func postWithImageAndText(imageKey:String,eventId:Int, message:String?, completion: @escaping (_ result: Bool)->()) {
        EventService.createPostMessage(eventId: eventId, message: message, urlImage: imageKey) { error in
            if error != nil {
                completion(false)
                return
            }
            completion(true)
        }
    }
}
