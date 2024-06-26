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
}
