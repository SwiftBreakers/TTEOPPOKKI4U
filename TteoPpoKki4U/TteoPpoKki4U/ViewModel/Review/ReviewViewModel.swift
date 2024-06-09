//
//  ReviewViewModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/8/24.
//

import Foundation
import Combine
import Firebase

class ReviewViewModel {
    
    let userManager = UserManager()
    
    var reviewPublisher = PassthroughSubject<Void, Error>()
    @Published var userReview = [ReviewModel]()
    
    func createReview(userDict: [String: Any]) {
        userManager.writeReview(userDict: userDict) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.reviewPublisher.send(completion: .failure(error))
            }
        }
    }
    
    func getUserReview() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        userManager.getMyReview(uid: uid) { [weak self] querySnapshot, error in
            self?.userReview.removeAll()
            if let error = error {
                self?.reviewPublisher.send(completion: .failure(error))
            }
            
            if let snapshotDocuments = querySnapshot?.documents {
                if !snapshotDocuments.isEmpty {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        guard
                            let uid = data["uid"] as? String,
                            let title = data["title"] as? String,
                            let storeName = data["storeName"] as? String,
                            let storeAddress = data["storeAddress"] as? String,
                            let content = data["content"] as? String,
                            let rating = data["rating"] as? Float,
                            let imageURL = data["imageURL"] as? [String],
                            let isActive = data["isActive"] as? Bool,
                            let createdAt = data["createdAt"] as? Timestamp,
                            let updatedAt = data["updatedAt"] as? Timestamp
                        else {
                            print("error")
                            return
                        }
                        let reviewData = ReviewModel(uid: uid, title: title, storeAddress: storeAddress, storeName: storeName, content: content, rating: rating, imageURL: imageURL, isActive: isActive, createdAt: createdAt, updatedAt: updatedAt)
                        self?.userReview.append(reviewData)
                        self?.reviewPublisher.send(())
                    }
                }
            }
        }
    }
    
    func editUserReview(uid: String, storeAddress: String, title: String, userDict: [String: Any]) {
        userManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self ] querySnapshot, error in
            if let error = error {
                self?.reviewPublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
                print(documents)
                for doc in documents {
                    let id = doc.documentID
                    reviewCollection.document(id).setData(userDict, merge: true)
                    print("edited")
                }
            }
        }
    }
    
    func removeUserReview(uid: String, storeAddress: String, title: String) {
        userManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self ] querySnapshot, error in
            if let error = error {
                self?.reviewPublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
              
                for doc in documents {
                    let id = doc.documentID
                    reviewCollection.document(id).delete()
                }
            }
        }
    }
}
