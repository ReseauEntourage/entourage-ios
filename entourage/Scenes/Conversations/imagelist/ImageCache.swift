//
//  ImageCache.swift
//  entourage
//
//  Created by Clement entourage on 02/10/2025.
//

import Foundation
import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {
        cache.countLimit = 500
        cache.totalCostLimit = 256 * 1024 * 1024 // ~256 Mo
    }
    
    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, for key: String, cost: Int? = nil) {
        cache.setObject(image, forKey: key as NSString, cost: cost ?? 0)
    }
    
    /// Charge une image depuis le cache ou le réseau.
    /// Le `completion` est **toujours** rappelé sur le thread principal.
    func load(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = image(for: urlString) {
            DispatchQueue.main.async { completion(cached) }
            return
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            var img: UIImage? = nil
            if let data = data, let decoded = UIImage(data: data) {
                img = decoded
                self?.set(decoded, for: urlString, cost: data.count)
            }
            DispatchQueue.main.async { completion(img) }
        }.resume()
    }
}
