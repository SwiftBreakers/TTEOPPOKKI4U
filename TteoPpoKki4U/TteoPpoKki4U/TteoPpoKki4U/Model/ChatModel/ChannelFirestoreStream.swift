//
//  ChannelFirestoreStream.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class ChannelFirestoreStream {
    private let storage = Storage.storage().reference()
    let firestoreDatabase = Firestore.firestore()
    var listener: ListenerRegistration?
    lazy var ChannelListener: CollectionReference = {
        return firestoreDatabase.collection("channels")
    }()
    
    func createChannel(with channelName: String) {
        let channel = Channel(name: channelName)
        ChannelListener.addDocument(data: channel.representation) { error in
            if let error = error {
                print("Error saving Channel: \(error.localizedDescription)")
            }
        }
    }
    
    func subscribe(completion: @escaping (Result<[(Channel, DocumentChangeType)], Error>) -> Void) {
        ChannelListener.addSnapshotListener { snaphot, error in
            guard let snapshot = snaphot else {
                completion(.failure(error!))
                return
            }
            
            let result = snapshot.documentChanges
                .filter { Channel($0.document) != nil }
                .compactMap { (Channel($0.document)!, $0.type) }
            
            completion(.success(result))
        }
    }
    
    func removeListener() {
        listener?.remove()
    }
}
