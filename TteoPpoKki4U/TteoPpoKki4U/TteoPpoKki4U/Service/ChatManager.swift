//
//  ChatManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/22/24.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseFirestore


class ChatManager {
    
    func getSenders(channelName: String, completion: @escaping ([String]) -> Void) {
        channelCollection.whereField(db_channelName, isEqualTo: channelName).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching channel: \(String(describing: error))")
                completion([])
                return
            }
            
            var senderIds = Set<String>()
            for document in snapshot.documents {
                let threadCollection = channelCollection.document(document.documentID).collection(db_thread)
                threadCollection.getDocuments { (threadSnapshot, error) in
                    guard let threadSnapshot = threadSnapshot, error == nil else {
                        print("Error fetching thread: \(String(describing: error))")
                        return
                    }
                    
                    for threadDocument in threadSnapshot.documents {
                        if let senderId = threadDocument.data()[db_senderId] as? String {
                            senderIds.insert(senderId)
                        }
                    }
                    completion(Array(senderIds))
                }
            }
        }
    }
    
}
