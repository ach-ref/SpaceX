//
//  ImageCache.swift
//  SpaceX
//
//  Created by Achref Marzouki on 09/11/2019.
//  Copyright © 2019 Achref Marzouki. All rights reserved.
//

import UIKit

import Alamofire

typealias ImageCacheCompletion = (UIImage?) -> Void
typealias DataCacheCompletion = (Data?) -> Void

class ImageCache: NSObject {
    
    // MARK: - NSCache
    
    private var cache: NSCache = NSCache<NSString, NSData>()
    
    // MARK: - Shared instance
    
    static let shared = ImageCache()
    
    // MARK: - Caching Methods
    
    func isImagePresentInCache(url: String) -> Bool {
        return cache.object(forKey: url as NSString) != nil
    }
    
    func getCachedImage(for url: String) -> UIImage? {
        let data = cache.object(forKey: url as NSString)
        return UIImage(data: data! as Data)
    }
    
    @discardableResult func save(image: UIImage, for url: String) -> Bool {
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            cache.setObject(data as NSData, forKey: url as NSString)
            return true
        }
        
        return false
    }
    
    @discardableResult func save(imageData: Data, for url: String) -> UIImage? {
        
        if let image = UIImage(data: imageData) {
            cache.setObject(imageData as NSData, forKey: url as NSString)
            return image
        }
        
        return nil
    }
    
    func displayImage(from url: String, completion: @escaping ImageCacheCompletion) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if !self.isImagePresentInCache(url: url) {
                if !url.isEmpty {
                    self.fetchImageData(from: url, completion: { (data) in
                        if let imageData = data, let image = UIImage(data: imageData) {
                            DispatchQueue.main.async { completion(image) }
                        }
                        else {
                            DispatchQueue.main.async { completion(nil) }
                        }
                    })
                }
                else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
            else {
                if let image = self.getCachedImage(for: url) {
                    DispatchQueue.main.async { completion(image) }
                }
                else {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        }
    }
    
    func clear() {
        DispatchQueue.global().async {
            self.cache.removeAllObjects()
        }
    }
    
    // MARK: - Helpers
    
    private func fetchImageData(from url: String, completion: @escaping DataCacheCompletion) {
        
        getImageData(from: url) { (data) in
            if let imageData = data, let _ = UIImage(data: imageData) {
                self.cache.setObject(imageData as NSData, forKey: url as NSString)
                completion(data)
            }
            else {
                completion(nil)
            }
        }
    }
    
    private func getImageData(from url: String, completion: @escaping DataCacheCompletion) {
        
        Alamofire.request(url).responseData { response in
            if let data = response.result.value {
                completion(data)
            }
            else {
                completion(nil)
            }
        }
    }
}
