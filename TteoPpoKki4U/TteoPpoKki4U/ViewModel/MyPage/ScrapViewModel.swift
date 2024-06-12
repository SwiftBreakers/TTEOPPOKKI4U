//
//  ScrapViewModel.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/11/24.
//

import Foundation
import Combine

//각각의 shopAddress, shopName에 FS에서 값 가져오는 로직 가져오기

class ScrapViewModel {
    let storeManager = StoreManager()
    
    @Published var scrapArray = [ScrapList]()
    var scrapPublisher = PassthroughSubject<Void, Error>()
    
    func fetchScrap(uid: String) {
        storeManager.requestScrap(uid: uid) { [weak self] querySnapshot, error in
            
            self?.scrapArray.removeAll()
            
            if let error = error {
                self?.scrapPublisher.send(completion: .failure(error))
            }
            
            if let docSnapshot = querySnapshot?.documents {
                for doc in docSnapshot {
                    let data = doc.data()
                    
                    guard let shopName = data[db_shopName] as? String,
                          let shopAddress = data[db_shopAddress] as? String
                    else {
                        return
                    }
                    
                    let model = ScrapList(shopName: shopName, shopAddress: shopAddress)
                    
                    self?.scrapArray.append(model)
                    self?.scrapPublisher.send(())
                }
            }
        }
    }
    
    func deleteScrap(uid: String, shopAddress: String) {
        storeManager.deleteScrap(uid: uid, shopAddress: shopAddress) { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let docSnapshot = querySnapshot?.documents {
                for doc in docSnapshot {
                    let id = doc.documentID
                    
                    scrappedCollection.document(id).delete()
                }
            }
        }
    }
}
