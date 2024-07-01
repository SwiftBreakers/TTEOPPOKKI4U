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
    var blockListener: ListenerRegistration?
    
    var messages = [Message]()
    var blockSenderSet = Set<String>()
    
    func subscribe(id: String, myUid: String?, completion: @escaping (Result<[Message], StreamError>) -> Void) {
        let streamPath = "channels/\(id)/thread"
        
        removeListener()
        collectionListener = firestoreDataBase.collection(streamPath)
        
        guard let myUid = myUid else {
            // 게스트 사용자의 경우 차단된 사용자 목록을 확인하지 않고 메시지를 구독
            listener = collectionListener?.whereField(db_isActive, isEqualTo: true)
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        completion(.failure(StreamError.firestoreError(error)))
                        return
                    }
                    
                    self.handleDocumentChanges(snapshot.documentChanges) { messages in
                        completion(.success(messages))
                    }
                }
            return
        }
        
        // 차단된 사용자 목록의 변화를 감지
        blockListener = blockCollection.document(myUid).addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            guard let document = snapshot, document.exists, let blockData = document.data(), let blockSenderArray = blockData[db_blockSenderNames] as? [String] else {
                self.blockSenderSet = Set<String>()
                self.reloadMessages(completion: completion)
                return
            }
            
            self.blockSenderSet = Set(blockSenderArray)
            self.reloadMessages(completion: completion)
        }
        
        // 메시지 변화를 감지
        listener = collectionListener?.whereField(db_isActive, isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    completion(.failure(StreamError.firestoreError(error)))
                    return
                }
                
                self.handleDocumentChanges(snapshot.documentChanges) { messages in
                    completion(.success(messages))
                }
            }
    }
    
    private func handleDocumentChanges(_ documentChanges: [DocumentChange], completion: @escaping ([Message]) -> Void) {
        var newMessages = [Message]()
        
        documentChanges.forEach { change in
            if var message = Message(document: change.document) {
                switch change.type {
                case .added:
                    if !blockSenderSet.contains(message.sender.displayName), !messages.contains(where: { $0.id == message.id }) {
                        newMessages.append(message)
                    }
                case .modified:
                    if let index = messages.firstIndex(where: { $0.id == message.id }) {
                        if blockSenderSet.contains(message.sender.displayName) {
                            messages.remove(at: index)
                        } else {
                            messages[index] = message
                        }
                    } else if !blockSenderSet.contains(message.sender.displayName) {
                        newMessages.append(message)
                    }
                case .removed:
                    messages.removeAll { $0.id == message.id }
                }
            }
        }
        
        self.messages += newMessages
        self.messages.sort()
        
        // 이미지가 있는 메시지의 경우 이미지 다운로드를 처리
        let messagesWithImages = newMessages.filter { $0.downloadURL != nil }
        let dispatchGroup = DispatchGroup()
        
        messagesWithImages.forEach { message in
            if let url = message.downloadURL {
                dispatchGroup.enter()
                FirebaseStorageManager.downloadImage(url: url) { result in
                    switch result {
                    case .success(let image):
                        if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                            self.messages[index].image = image
                        }
                    case .failure(let error):
                        print("Failed to download image: \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(self.messages)
        }
    }
    
    private func reloadMessages(completion: @escaping (Result<[Message], StreamError>) -> Void) {
        collectionListener?.whereField(db_isActive, isEqualTo: true).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(StreamError.firestoreError(error)))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(StreamError.noData(error)))
                return
            }
            
            self.messages = snapshot.documents.compactMap { document in
                let message = Message(document: document)
                return self.blockSenderSet.contains(message?.sender.displayName ?? "") ? nil : message
            }
            self.messages.sort()
            completion(.success(self.messages))
        }
    }
    
    func save(_ message: Message, completion: ((Error?) -> Void)? = nil) {
        collectionListener?.addDocument(data: message.representation) { error in
            completion?(error)
        }
    }
    
    func removeListener() {
        listener?.remove()
        blockListener?.remove()
    }
}
