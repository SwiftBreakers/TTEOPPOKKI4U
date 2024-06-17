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
    
    func addReportCount(uid: String, storeAddress: String, title: String, completion: @escaping () -> Void) {
        manageManager.getSpecificReview(uid: uid, storeAddress: storeAddress, title: title) { [weak self] querySnapshot, error in
            
            if let error = error {
                self?.managePublisher.send(completion: .failure(error))
            }
            
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let id = doc.documentID
                    let data = doc.data()
                    guard let reportCount = data[db_reportCount] as? Int else { return }
                    let count = [db_reportCount: reportCount + 1]
                    reviewCollection.document(id).setData(count, merge: true)
                    self?.managePublisher.send(())
                    completion()
                }
            }
        }
    }
    
}
