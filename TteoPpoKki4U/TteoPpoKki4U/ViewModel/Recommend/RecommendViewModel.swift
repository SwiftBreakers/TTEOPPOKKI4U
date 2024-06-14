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
import FirebaseAuth

public class CardViewModel: ObservableObject {
    
    @Published var cards: [Card] = []
    @Published var bookmarked: [Bookmarked] = []
    private var db: Firestore!
    private var storage: Storage!
    private var cancellables = Set<AnyCancellable>()
    var userID = Auth.auth().currentUser!.uid
    @Published var isBookmarked: Bool = false
    
    
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
                        
                        await self.fetchBookmarkStatus(title: title)
                        
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
    
    func fetchBookmarkStatus(title: String) async {
            let query = bookmarkedCollection
                .whereField(db_uid, isEqualTo: userID)
                .whereField(db_title, isEqualTo: title)
            
            do {
                let querySnapshot = try await query.getDocuments()
                let isBookmarked = !querySnapshot.documents.isEmpty
                DispatchQueue.main.async {
                    self.isBookmarked = isBookmarked
                }
            } catch {
                print("Error getting documents: \(error)")
                DispatchQueue.main.async {
                    self.isBookmarked = false
                }
            }
        }
    func createBookmarkItem(title: String, imageURL: String) {
        
        bookmarkedCollection.addDocument(data: [db_title: title, db_imageURL: imageURL, db_uid: userID]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self.isBookmarked = true
            }
        }
    }
    func deleteBookmarkItem(title: String) {
        bookmarkedCollection
            .whereField(db_uid, isEqualTo: userID)
            .whereField(db_title, isEqualTo: title)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        bookmarkedCollection.document(document.documentID).delete() { error in
                            if let error = error {
                                print("Error removing document: \(error)")
                            } else {
                                self.isBookmarked = false
                            }
                        }
                    }
                }
            }
    }
}


