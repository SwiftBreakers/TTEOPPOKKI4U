//
//  ManageViewModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import Foundation
import Combine
import Firebase

class ManageViewModel {
    
    private let manageManager: ManageManager
    
    init(manageManager: ManageManager) {
        self.manageManager = manageManager
    }
    
    var managePublisher = PassthroughSubject<Void, Error>()
    @Published var userReview = [ReviewModel]()
    @Published var userArray = [UserModel]()
    
    func getUsers() {
        manageManager.fetchUsers { [weak self] error, dataSnapshot in
            self?.userArray.removeAll()
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            guard let dictionary = dataSnapshot?.value as? [String: [String: Any]] else { return }
            
            for (uid, userDict) in dictionary {
                let email = userDict[db_email] as? String ?? ""
                let nickName = userDict[db_nickName] as? String ?? ""
                let profileImageUrl = userDict[db_profileImageUrl] as? String ?? ""
                let isBlockInt = userDict[db_isBlock] as? Int ?? 0
                let isBlock = isBlockInt != 0
                
                let model = UserModel(uid: uid, email: email, isBlock: isBlock, nickName: nickName, profileImageUrl: profileImageUrl)
                self?.userArray.append(model)
            }
            self?.managePublisher.send(())
        }
    }
    
    func getUsers(completion: @escaping () -> Void) {
        manageManager.fetchUsers { [weak self] error, dataSnapshot in
            self?.userArray.removeAll()
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            guard let dictionary = dataSnapshot?.value as? [String: [String: Any]] else { return }
            
            for (uid, userDict) in dictionary {
                let email = userDict[db_email] as? String ?? ""
                let nickName = userDict[db_nickName] as? String ?? ""
                let profileImageUrl = userDict[db_profileImageUrl] as? String ?? ""
                let isBlockInt = userDict[db_isBlock] as? Int ?? 0
                let isBlock = isBlockInt != 0
                
                let model = UserModel(uid: uid, email: email, isBlock: isBlock, nickName: nickName, profileImageUrl: profileImageUrl)
                self?.userArray.append(model)
            }
            self?.managePublisher.send(())
            completion()
        }
    }
    
    func getReviews() {
        manageManager.fetchUserReviews { [weak self] querySnapshot, error in
            self?.userReview.removeAll()
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
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
                        let reviewData = ReviewModel(uid: uid,
                                                     title: title,
                                                     storeAddress: storeAddress,
                                                     storeName: storeName,
                                                     content: content,
                                                     rating: rating,
                                                     imageURL: imageURL,
                                                     isActive: isActive,
                                                     createdAt: createdAt,
                                                     updatedAt: updatedAt,
                                                     reportCount: reportCount)
                        self?.userReview.append(reviewData)
                        self?.managePublisher.send(())
                    }
                }
            }
        }
    }
    
    func activateUser(uid: String, completion: @escaping ()-> Void) {
        let values = [db_isBlock: false]
        manageManager.editSpecificUser(uid: uid, values: values) { [weak self] error, reference in
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            self?.managePublisher.send(())
            completion()
        }
    }
    
    func deactivateUser(uid: String, completion: @escaping ()-> Void) {
        let values = [db_isBlock: true]
        manageManager.editSpecificUser(uid: uid, values: values) { [weak self] error, reference in
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            self?.managePublisher.send(())
            completion()
        }
    }
    
    
    func activateReview(uid: String, storeAddress: String, title: String, completion: @escaping () -> Void) {
        
        let data = [db_isActive: true]
        
        manageManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self] querySnapshot, error in
            
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let id = doc.documentID
                    reviewCollection.document(id).setData(data, merge: true)
                    self?.managePublisher.send(())
                    completion()
                }
            }
        }
    }
    
    func deactivateReview(uid: String, storeAddress: String, title: String, completion: @escaping () -> Void) {
        
        let data = [db_isActive: false]
        
        manageManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self] querySnapshot, error in
            
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let id = doc.documentID
                    reviewCollection.document(id).setData(data, merge: true)
                    self?.managePublisher.send(())
                    completion()
                }
            }
        }
        
    }
    
    
}

