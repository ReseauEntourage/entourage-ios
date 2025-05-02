//
//  ContribUploadPictureService.swift
//  entourage
//
//  Created by Jerome on 02/08/2022.
//

import Foundation
struct ContribUploadPictureService {
    
    //First step Prepare
    static func prepareUploadWith(image:UIImage, action:Action, isUpdate:Bool ,autoPost:Bool, completion: @escaping (_ action:Action?, _ isOk: Bool)->()) {
        
        guard let token = UserDefaults.token else {return}
        var endpoint = API_URL_CONTRIB_PREPARE_IMAGE_UPLOAD
        endpoint = String.init(format: endpoint, token)
        
        AuthService.prepareUploadPhotoS3(endpoint:endpoint) { json, error in
            guard let _presigneUrl = json?["presigned_url"] as? String, let _uploadKey = json?["upload_key"] as? String else {
                completion(nil, false)
                return
            }
            
            uploadtoS3(urlS3: _presigneUrl, image: image, completion: {isOk in
                if isOk {
                    postWithImageAndText(imageKey: _uploadKey,action: action,isUpadte: isUpdate, autoPost: autoPost, completion: { action, isOk in
                        completion(action, isOk)
                    })
                }
                else {
                    completion(nil, false)
                }
            })
        }
    }
    
    //2nd step upload to Amazon
    private static func uploadtoS3(urlS3:String, image:UIImage,completion: @escaping (_ result: Bool)->()) {
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
    
    //3nd step create contrib with key
    private static func postWithImageAndText(imageKey:String, action:Action,isUpadte:Bool,autoPost:Bool, completion: @escaping (_ action:Action?,_ isOk: Bool)->()) {
        Logger.print("***** image key ? \(imageKey)")
        var newAction = action
        newAction.keyImage = imageKey
        if isUpadte {
            ActionsService.updateAction(isContrib: true, action: newAction, autoPost: autoPost) { action, error in
                if error != nil {
                    completion(nil,false)
                    return
                }
                completion(action, true)
            }
        }
        else {
            ActionsService.createAction(isContrib: true, action: newAction, autoPost: autoPost) { action, error in
                if error != nil {
                    completion(nil,false)
                    return
                }
                completion(action, true)
            }
        }
    }
}

