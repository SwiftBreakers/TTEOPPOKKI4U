//
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
    let storeManager = StoreManager()
    
    var reviewPublisher = PassthroughSubject<Void, Error>()
    @Published var userReview = [ReviewModel]()
    @Published var userInfo = [UserModel]()

    
    func createReview(userDict: [String: Any], completion: @escaping () -> Void) {
        userManager.writeReview(userDict: userDict) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.reviewPublisher.send(completion: .failure(error))
            }
            completion()
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
                            let uid = data[db_uid] as? String,
                            let title = data[db_title] as? String,
                            let storeName = data[db_storeName] as? String,
                            let storeAddress = data[db_storeAddress] as? String,
                            let content = data[db_content] as? String,
                            let rating = data[db_rating] as? Float,
                            let imageURL = data[db_imageURL] as? [String],
                            let isActive = data[db_isActive] as? Bool,
                            let createdAt = data[db_createdAt] as? Timestamp,
                            let updatedAt = data[db_updatedAt] as? Timestamp,
                            let reportCount = data[db_reportCount] as? Int
                        else {
                            print("error")
                            return
                        }
                        let reviewData = ReviewModel(uid: uid, title: title, storeAddress: storeAddress, storeName: storeName, content: content, rating: rating, imageURL: imageURL, isActive: isActive, createdAt: createdAt, updatedAt: updatedAt, reportCount: reportCount)
                        self?.userReview.append(reviewData)
                        self?.reviewPublisher.send(())
                    }
                }
            }
        }
    }
    
    func getUserReview(completion: @escaping ()->Void) {
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
                            let uid = data[db_uid] as? String,
                            let title = data[db_title] as? String,
                            let storeName = data[db_storeName] as? String,
                            let storeAddress = data[db_storeAddress] as? String,
                            let content = data[db_content] as? String,
                            let rating = data[db_rating] as? Float,
                            let imageURL = data[db_imageURL] as? [String],
                            let isActive = data[db_isActive] as? Bool,
                            let createdAt = data[db_createdAt] as? Timestamp,
                            let updatedAt = data[db_updatedAt] as? Timestamp,
                            let reportCount = data[db_reportCount] as? Int
                        else {
                            print("error")
                            return
                        }
                        let reviewData = ReviewModel(uid: uid, title: title, storeAddress: storeAddress, storeName: storeName, content: content, rating: rating, imageURL: imageURL, isActive: isActive, createdAt: createdAt, updatedAt: updatedAt, reportCount: reportCount)
                        self?.userReview.append(reviewData)
                        self?.reviewPublisher.send(())
                        completion()
                    }
                }
            }
        }
    }
    
    func editUserReview(uid: String, storeAddress: String, title: String, userDict: [String: Any], completion: @escaping () -> Void) {
        userManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self ] querySnapshot, error in
            if let error = error {
                self?.reviewPublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let id = doc.documentID
                    reviewCollection.document(id).setData(userDict, merge: true)
                    self?.reviewPublisher.send(())
                    completion()
                }
            }
        }
    }
    
    func removeUserReview(uid: String, storeAddress: String, title: String, completion: @escaping () -> Void) {
        userManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self ] querySnapshot, error in
            if let error = error {
                self?.reviewPublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
              
                for doc in documents {
                    let id = doc.documentID
                    reviewCollection.document(id).delete()
                    completion()
                }
            }
        }
    }
    
    func getStoreReview(storeName: String, storeAddress: String) {
            storeManager.requestStore(storeName: storeName, storeAddress: storeAddress) { [weak self] querySnapshot, error in
                self?.userReview.removeAll()
                self?.userInfo.removeAll()
                if let error = error {
                    self?.reviewPublisher.send(completion: .failure(error))
                    return
                }
                
                guard let snapshotDocuments = querySnapshot?.documents else { return }
                
                if !snapshotDocuments.isEmpty {
                    let dispatchGroup = DispatchGroup()
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        guard
                            let uid = data[db_uid] as? String,
                            let title = data[db_title] as? String,
                            let storeName = data[db_storeName] as? String,
                            let storeAddress = data[db_storeAddress] as? String,
                            let content = data[db_content] as? String,
                            let rating = data[db_rating] as? Float,
                            let imageURL = data[db_imageURL] as? [String],
                            let isActive = data[db_isActive] as? Bool,
                            let createdAt = data[db_createdAt] as? Timestamp,
                            let updatedAt = data[db_updatedAt] as? Timestamp,
                            let reportCount = data[db_reportCount] as? Int
                        else {
                            print("error")
                            continue
                        }
                        
                        dispatchGroup.enter()
                        self?.getUserInfo(uid: uid) { userModel in
                            let reviewData = ReviewModel(uid: uid, title: title, storeAddress: storeAddress, storeName: storeName, content: content, rating: rating, imageURL: imageURL, isActive: isActive, createdAt: createdAt, updatedAt: updatedAt, reportCount: reportCount)
                            self?.userReview.append(reviewData)
                            if let userModel = userModel {
                                self?.userInfo.append(userModel)
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self?.reviewPublisher.send(())
                    }
                }
            }
        }
    
    func getUserInfo(uid: String, completion: @escaping (UserModel?) -> Void) {
        userManager.fetchUserData(uid: uid) { error, snapshot in
            if let error = error {
                self.reviewPublisher.send(completion: .failure(error))
                completion(nil)
                return
            }
            
            if let dictionary = snapshot?.value as? [String: Any] {
                let email = dictionary[db_email] as? String ?? ""
                let nickName = dictionary[db_nickName] as! String == "" ? "익명의 떡볶커" : dictionary[db_nickName] as! String
                let profileImageUrl = dictionary[db_profileImageUrl] as? String ?? ""
                let isBlockInt = dictionary[db_isBlock] as? Int ?? 0
                let isBlock = isBlockInt != 0
                
                let model = UserModel(uid: uid, email: email, isBlock: isBlock, nickName: nickName, profileImageUrl: profileImageUrl)
                completion(model)
            } else {
                let model = UserModel(uid: "", email: "", isBlock: false, nickName: "익명의 떡볶커", profileImageUrl: "")
                completion(model)
            }
        }
    }
    
    func timestampToString(value: Timestamp) -> String {
        let date = value.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let result = dateFormatter.string(from: date)
        return result
    }
}
