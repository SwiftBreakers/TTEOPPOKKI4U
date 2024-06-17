//
//  ReportViewModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/16/24.
//

import Foundation
import Combine
import Firebase

class ReportViewModel {
    
    private let manageManager = ManageManager()
    
    var managePublisher = PassthroughSubject<Void, Error>()
    
    func addReportCount(uid: String, storeAddress: String, title: String) async throws {
        let querySnapshot = try await manageManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title)
        
        if let documents = querySnapshot?.documents {
            for doc in documents {
                let id = doc.documentID
                let data = doc.data()
                guard let reportCount = data[db_reportCount] as? Int else { return }
                let count = [db_reportCount: reportCount + 1]
                try await reviewCollection.document(id).setData(count, merge: true)
                managePublisher.send(())
            }
        }
    }
    
    func addReport(reportData: [String: Any]) async throws {
        try await manageManager.addReport(data: reportData)
        managePublisher.send(())
    }
    
    func addReportAndIncreaseCount(uid: String, storeAddress: String, title: String, reportData: [String: Any]) async {
        do {
            try await addReportCount(uid: uid, storeAddress: storeAddress, title: title)
            try await addReport(reportData: reportData)
        } catch {
            managePublisher.send(completion: .failure(error))
        }
    }
}
