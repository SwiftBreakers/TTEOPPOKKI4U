//
//  ManageManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/12/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ManageManager {
    
    let ref = Database.database().reference()
    
    func fetchUsers(completion: @escaping ((any Error)?, DataSnapshot?) -> Void) {
        ref.child(db_user_users).getData(completion: completion)
    }
    
    func editSpecificUser(uid: String, values: [String: Any], completion: @escaping ((any Error)?, DatabaseReference) -> Void) {
        ref.child(db_user_users).child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func getSpecificReview(uid: String, storeAddress: String, title: String, completion: @escaping(QuerySnapshot?, (Error)?) -> Void) {
        reviewCollection.whereField(db_uid, isEqualTo: uid).whereField(db_storeAddress, isEqualTo: storeAddress).whereField(db_title , isEqualTo: title).getDocuments(completion: completion)
    }
    
    func fetchUserReviews(completion: @escaping (QuerySnapshot?, (any Error)?) -> Void) {
        reviewCollection.getDocuments(completion: completion)
    }
    
    func getUserReview(uid: String, completion: @escaping (QuerySnapshot?, (any Error)?) -> Void) {
        reviewCollection.whereField(db_uid, isEqualTo: uid).getDocuments(completion: completion)
    }
    
    func addReport(data: [String: Any]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            reportCollection.addDocument(data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func getSpecificReview(uid: String, storeAddress: String, title: String) async throws -> QuerySnapshot? {
        return try await withCheckedThrowingContinuation { continuation in
            reviewCollection.whereField(db_uid, isEqualTo: uid)
                .whereField(db_storeAddress, isEqualTo: storeAddress)
                .whereField(db_title, isEqualTo: title)
                .getDocuments { querySnapshot, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: querySnapshot)
                    }
                }
        }
    }
    func getSpecificChatReport(content: String, channel: String, senderId: String) async throws -> QuerySnapshot? {
        return try await withCheckedThrowingContinuation { continuation in
            chatReportCollection.whereField(db_messageConetent, isEqualTo: content)
                .whereField(db_channel, isEqualTo: channel)
                .whereField(db_senderId, isEqualTo: senderId)
                .getDocuments { querySnapshot, error in
                    print(channel)
                    print(content)
                    print(senderId)
                    if let error = error {
                        print("Error fetching documents: \(error)")
                        continuation.resume(throwing: error)
                    } else {
                        if let querySnapshot = querySnapshot {
                            print("Fetched documents: \(querySnapshot)")
                        } else {
                            print("No documents found for uid: \(content)")
                        }
                        continuation.resume(returning: querySnapshot)
                    }
                }
        }
    }
    
    func chatAddReport(data: [String: Any]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            chatReportCollection.addDocument(data: data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
