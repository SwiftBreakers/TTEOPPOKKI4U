//
//  ChatFirestoreStream.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ChatFirestoreStream {
    
    private let storage = Storage.storage().reference()
    let firestoreDataBase = Firestore.firestore()
    var listener: ListenerRegistration?
    var collectionListener: CollectionReference?
    
    func subscribe(id: String, completion: @escaping (Result<[Message], StreamError>) -> Void) {
        let streamPath = "channels/\(id)/thread"
        
        removeListener()
        collectionListener = firestoreDataBase.collection(streamPath)
        
        listener = collectionListener?.whereField(db_isActive, isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion(.failure(StreamError.firestoreError(error)))
                    return
                }
                
                var messages = [Message]()
                snapshot.documentChanges.forEach { change in
                    if let message = Message(document: change.document) {
                        if case .added = change.type {
                            messages.append(message)
                        }
                    }
                }
                completion(.success(messages))
            }
    }
    
    func save(_ message: Message, completion: ((Error?) -> Void)? = nil) {
        collectionListener?.addDocument(data: message.representation) { error in
            completion?(error)
        }
    }
    
    func removeListener() {
        listener?.remove()
    }
}
