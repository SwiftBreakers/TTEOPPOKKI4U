//
//  BookmarkViewModel.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/13/24.
//

import Foundation
import Combine



class BookmarkViewModel {
    let storeManager = StoreManager()
    
    @Published var bookmarkArray = [BookmarkList]()
    var bookmarkPublisher = PassthroughSubject<Void, Error>()
    
    func fetchBookmark(uid: String) {
        storeManager.requestBookmark(uid: uid) { [weak self] querySnapshot, error in
            
            self?.bookmarkArray.removeAll()
            
            if let error = error {
                self?.bookmarkPublisher.send(completion: .failure(error))
            }
            
            if let docSnapshot = querySnapshot?.documents {
                for doc in docSnapshot {
                    let data = doc.data()
                    
                    guard let title = data[db_title] as? String,
                          let imageURL = data[db_imageURL] as? String
                    else {
                        return
                    }
                    
                    let model = BookmarkList(title: title, imageURL: imageURL)
                    
                    self?.bookmarkArray.append(model)
                    self?.bookmarkPublisher.send(())
                }
            }
        }
    }
    
    func deleteBookmark(uid: String, title: String) {
        storeManager.deleteBookmark(uid: uid, title: title) { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let docSnapshot = querySnapshot?.documents {
                for doc in docSnapshot {
                    let id = doc.documentID
                    
                    bookmarkedCollection.document(id).delete()
                }
            }
        }
    }
}
