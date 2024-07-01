//
//  ChatReportViewModel.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/25.
//

import Foundation
import Combine
import Firebase

class ChatReportViewModel {
    
    private let manageManager = ManageManager()
    
    var managePublisher = PassthroughSubject<Void, Error>()
    
    func addReportCount(content: String, channel: String, senderId: String) async throws {
        let querySnapshot = try await manageManager.getSpecificChatReport(content: content, channel: channel, senderId: senderId)
        
        
        if let documents = querySnapshot?.documents {
            for doc in documents {
                let id = doc.documentID
                let data = doc.data()
                guard let reportCount = data[db_reportCount] as? Int else { return }
                let count = [db_reportCount: reportCount + 1]
                try await chatReportCollection.document(id).setData(count, merge: true)
                managePublisher.send(())
            }
        }
    }
    
    func addReport(reportData: [String: Any]) async throws {
        try await manageManager.chatAddReport(data: reportData)
        managePublisher.send(())
    }
    
    func addReportAndIncreaseCount(content: String, channel: String, senderId: String, reportData: [String: Any]) async {
        do {
            try await addReportCount(content: content, channel: channel, senderId: senderId)
            try await addReport(reportData: reportData)
        } catch {
            managePublisher.send(completion: .failure(error))
        }
    }
    
    func fetchFilteredMessages(forChannelName channelName: String, senderId: String, content: String, isSexual: Bool) async {
        do {
            let channelSnapshot = try await channelCollection.whereField(db_channelName, isEqualTo: channelName).getDocuments()
            
            for channelDocument in channelSnapshot.documents {
                let channelId = channelDocument.documentID
                
                let threadSnapshot = try await channelCollection.document(channelId).collection(db_thread)
                    .whereField(db_senderId, isEqualTo: senderId)
                    .whereField(db_content, isEqualTo: content)
                    .getDocuments()
                
                for threadDocument in threadSnapshot.documents {
                    let data = threadDocument.data()
                    let id = threadDocument.documentID
                    if let reportCount = data[db_chatReportCount] as? Int, let isActive = data[db_isActive] as? Bool {
                        var dict = [String: Any]()
                        
                        if reportCount >= 2 || isSexual {
                            dict = [db_chatReportCount: reportCount + 1, db_isActive: false]
                        } else {
                            dict = [db_chatReportCount: reportCount + 1]
                        }
                        try await channelCollection.document(channelId).collection(db_thread).document(id).setData(dict, merge: true)
                    }
                }
            }
        } catch {
            print("Error fetching channels or threads: \(error)")
        }
    }
    
    func fetchFilteredImages(forChannelName channelName: String, senderId: String, url: String, isSexual: Bool) async {
        do {
            let channelSnapshot = try await channelCollection.whereField(db_channelName, isEqualTo: channelName).getDocuments()
            
            for channelDocument in channelSnapshot.documents {
                let channelId = channelDocument.documentID
                
                let threadSnapshot = try await channelCollection.document(channelId).collection(db_thread)
                    .whereField(db_senderId, isEqualTo: senderId)
                    .whereField(db_url, isEqualTo: url)
                    .getDocuments()
                
                for threadDocument in threadSnapshot.documents {
                    let data = threadDocument.data()
                    let id = threadDocument.documentID
                    if let reportCount = data[db_chatReportCount] as? Int {
                        var dict = [String: Any]()
                        
                        if reportCount >= 2 || isSexual {
                            dict = [db_chatReportCount: reportCount + 1, db_isActive: false]
                        } else {
                            dict = [db_chatReportCount: reportCount + 1]
                        }
                        try await channelCollection.document(channelId).collection(db_thread).document(id).setData(dict, merge: true)
                    }
                }
            }
        } catch {
            print("Error fetching channels or threads: \(error)")
        }
    }
    
    func addBlockUser(myUid: String, senderName: String) {
        let userBlockRef = blockCollection.document(myUid)
        
        userBlockRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 문서가 존재하면 blockSenderName에 새로운 senderName 추가
                if var blockData = document.data(), let blockSenderNameArray = blockData[db_blockSenderNames] as? [String] {
                    var blockSenderNameSet = Set(blockSenderNameArray)
                    blockSenderNameSet.insert(senderName)
                    blockData[db_blockSenderNames] = Array(blockSenderNameSet)
                    
                    userBlockRef.setData(blockData, merge: true) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            } else {
                // 문서가 존재하지 않으면 새로 생성
                let newUserBlock = UserBlock(myUid: myUid, blockSenderNames: [senderName])
                userBlockRef.setData(newUserBlock.toDictionary(), merge: true) { error in
                    if let error = error {
                        print("Error creating document: \(error)")
                    } else {
                        print("Document successfully created")
                    }
                }
            }
        }
    }
    
    func fetchBlockedUsers(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let myUid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        blockCollection.document(myUid).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists, let blockData = document.data(), let blockSenderNamesArray = blockData[db_blockSenderNames] as? [String] else {
                completion(.success([]))
                return
            }
            
            completion(.success(blockSenderNamesArray))
        }
    }

    func unblockUser(myUid: String, senderName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        blockCollection.document(myUid).updateData([
            db_blockSenderNames: FieldValue.arrayRemove([senderName])
        ]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }
    
}
