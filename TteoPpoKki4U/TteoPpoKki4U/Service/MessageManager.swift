//
//  MessageManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import FirebaseFirestore

class MessageManager {
    private let db = Firestore.firestore()

    func sendMessage(chatRoomId: String, text: String, senderId: String, senderName: String, completion: @escaping (Error?) -> Void) {
        let messageRef = db.collection("chatRooms").document(chatRoomId).collection("messages").document()
        let messageData: [String: Any] = [
            "text": text,
            "senderId": senderId,
            "senderName": senderName,
            "createdAt": FieldValue.serverTimestamp()
        ]
        messageRef.setData(messageData, completion: completion)
    }

    func listenForMessages(chatRoomId: String, completion: @escaping ([Message]) -> Void) {
        db.collection("chatRooms").document(chatRoomId).collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let messages = documents.map { doc -> Message in
                    let data = doc.data()
                    let id = doc.documentID
                    let text = data["text"] as? String ?? ""
                    let senderId = data["senderId"] as? String ?? ""
                    let senderName = data["senderName"] as? String ?? ""
                    let createdAt = data["createdAt"] as? Timestamp ?? Timestamp()
                    return Message(id: id, text: text, senderId: senderId, senderName: senderName, createdAt: createdAt)
                }
                completion(messages)
            }
    }
}
