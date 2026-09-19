//
//  EventCoverUploadPictureService.swift
//  entourage
//
//

import Foundation
import UIKit

struct EventCoverUploadPictureService {

    static func prepareUploadWith(image:UIImage, completion: @escaping (_ uploadKey: String?)->()) {

        guard let token = UserDefaults.token else {
            completion(nil)
            return
        }
        var endpoint = API_URL_EVENT_PREPARE_IMAGE_UPLOAD
        endpoint = String.init(format: endpoint, token)

        AuthService.prepareUploadPhotoS3(endpoint:endpoint) { json, error in
            guard let _presigneUrl = json?["presigned_url"] as? String, let _uploadKey = json?["upload_key"] as? String else {
                completion(nil)
                return
            }

            uploadtoS3(urlS3: _presigneUrl, image: image, completion: {isOk in
                if isOk {
                    completion(_uploadKey)
                }
                else {
                    completion(nil)
                }
            })
        }
    }

    //2nd step upload to Amazon
    private static func uploadtoS3(urlS3:String, image:UIImage,completion: @escaping (_ result: Bool)->()) {
        let normalizedImage = image.normalizedImage()
        guard let url = URL(string: urlS3), let data = normalizedImage.jpegData(compressionQuality: 0.8) else {
            completion(false)
            return
        }

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")

        let task = session.uploadTask(with: request, from: data) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async {
                if (error == nil) {
                    completion(true)
                }
                else {
                    Logger.print("URL Session Task Failed: %@", error?.localizedDescription ?? "")
                    completion(false)
                }
            }
        }

        task.resume()
        session.finishTasksAndInvalidate()
    }
}
