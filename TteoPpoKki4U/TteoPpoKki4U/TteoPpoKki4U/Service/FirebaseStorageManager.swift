//
//  FirebaseStorageManager.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import Foundation
import FirebaseStorage
import UIKit
import Kingfisher

struct FirebaseStorageManager {
    static let cache = ImageCache.default
    
    static func uploadImage(image: UIImage, channel: Channel, progress: ((Double) -> Void)? = nil, completion: @escaping (Result<URL, Error>) -> Void) -> StorageUploadTask? {
        guard let channelId = channel.id,
              let data = image.jpegData(compressionQuality: 0.4) else { // jpg 포맷 사용
            completion(.failure(NSError(domain: "ImageUploadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare image for upload"])))
            return nil
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg" // jpg 포맷 사용
        
        let imageName = UUID().uuidString + String(Date().timeIntervalSince1970)
        let imageReference = Storage.storage().reference().child("\(channelId)/\(imageName)")
        
        let uploadTask = imageReference.putData(data, metadata: metaData) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            imageReference.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    completion(.failure(NSError(domain: "ImageUploadError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            progress?(percentComplete)
        }
        
        return uploadTask
    }
    
    static func downloadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // 먼저 캐시에서 이미지를 확인
        if let cachedImage = cache.retrieveImageInMemoryCache(forKey: url.absoluteString) {
            completion(.success(cachedImage))
            return
        }
        
        cache.retrieveImage(forKey: url.absoluteString) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    completion(.success(image))
                    return
                }
            case .failure:
                break
            }
            
            let reference = Storage.storage().reference(forURL: url.absoluteString)
            // 최대 크기를 2MB로 증가
            let fiftyMegabytes = Int64(2 * 1024 * 1024)
            
            reference.getData(maxSize: fiftyMegabytes) { data, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let imageData = data, let image = UIImage(data: imageData) else {
                    completion(.failure(NSError(domain: "ImageDownloadError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])))
                    return
                }
                
                // 이미지를 캐시에 저장
                cache.store(image, forKey: url.absoluteString)
                
                completion(.success(image))
            }
        }
    }
}

