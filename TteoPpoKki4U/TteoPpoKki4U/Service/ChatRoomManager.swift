//
//  ChatRoomManager.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import FirebaseFirestore

class ChatRoomManager {
    private let db = Firestore.firestore()

    func createChatRoom(name: String, createdBy: String, completion: @escaping (Error?) -> Void) {
        let chatRoomRef = db.collection("chatRooms").document()
        let chatRoomData: [String: Any] = [
            "name": name,
            "createdBy": createdBy,
            "createdAt": FieldValue.serverTimestamp(),
            "members": [createdBy]
        ]
        chatRoomRef.setData(chatRoomData, completion: completion)
    }

    func joinChatRoom(chatRoomId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let chatRoomRef = db.collection("chatRooms").document(chatRoomId)
        chatRoomRef.updateData([
            "members": FieldValue.arrayUnion([userId])
        ], completion: completion)
    }
}
