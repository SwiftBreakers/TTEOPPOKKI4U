//
//  RecommendViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

public class CardViewModel: ObservableObject {
    
    @Published var cards: [Card] = []
    private var db: Firestore!
    private var storage: Storage!
    private var cancellables = Set<AnyCancellable>()
    
    
    public var numberOfCards: Int {
        return cards.count
    }
    
    public init() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        storage = Storage.storage()
    }
    
    public func fetchData() async {
        let cardRef = db.collection("recommendMain")
        do {
            let querySnapshot = try await cardRef.getDocuments()
            
            let cards = try await withThrowingTaskGroup(of: Card?.self) { taskGroup in
                for document in querySnapshot.documents {
                    taskGroup.addTask {
                        let data = document.data()
                        let title = data["title"] as? String ?? "No Title"
                        let description = data["description"] as? String ?? "No Description"
                        let imageURLString = data["imageURL"] as? String ?? ""
                        let longDescription = data["longDescription"] as? String ?? "No LongDescription"
                        let shopAddress = data["shopAddress"] as? String ?? "No ShopAddress"
                        
                        // gs:// URL을 HTTP(S) URL로 변환
                        let imageURL = try await self.convertGSURLToHTTPURL(gsURL: imageURLString)
                        
                        return Card(title: title, description: description, longDescription: longDescription, imageURL: imageURL, shopAddress: shopAddress)
                    }
                }
                
                var newCards: [Card] = []
                for try await card in taskGroup {
                    if let card = card {
                        newCards.append(card)
                    }
                }
                return newCards
            }
            
            DispatchQueue.main.async {
                self.cards = cards
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    private func convertGSURLToHTTPURL(gsURL: String) async throws -> String {
        guard gsURL.starts(with: "gs://") else { return gsURL }
        
        let reference = storage.reference(forURL: gsURL)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }
    
    public func card(at index: Int) -> Card {
        return cards[index]
    }
}


