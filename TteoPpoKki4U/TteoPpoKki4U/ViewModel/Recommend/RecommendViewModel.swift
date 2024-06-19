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
    private var db: Firestore!
    private var storage: Storage!
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isBookmarked: Bool = false
    private var bookmarkStatus: [String: Bool] = [:]
    
    
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
            var fetchedCards: [Card] = []
            let cards = try await withThrowingTaskGroup(of: Card?.self) { taskGroup in
                for document in querySnapshot.documents {
                    taskGroup.addTask {
                        let data = document.data()
                        let title = data["title"] as? String ?? "No Title"
                        let description = data["description"] as? String ?? "No Description"
                        let imageURLString = data["imageURL"] as? String ?? ""
                        let longDescription1 = data["longDescription1"] as? String ?? "No LongDescription1"
                        let longDescription2 = data["longDescription2"] as? String ?? "No LongDescription2"
                        let shopAddress = data["shopAddress"] as? String ?? "No ShopAddress"
                        let queryName = data["queryName"] as? String ?? "No queryName"
                        let collectionImageURL1String = data["collectionImageURL1"] as? String ?? ""
                        let collectionImageURL2String = data["collectionImageURL2"] as? String ?? ""
                        let collectionImageURL3String = data["collectionImageURL3"] as? String ?? ""
                        let collectionImageURL4String = data["collectionImageURL4"] as? String ?? ""
                        let order = data["order"] as? Int ?? 0
                        // gs:// URL을 HTTP(S) URL로 변환
                        let imageURL = try await self.convertGSURLToHTTPURL(gsURL: imageURLString)
                        let collectionImageURL1 = try await self.convertGSURLToHTTPURL(gsURL: collectionImageURL1String)
                        let collectionImageURL2 = try await self.convertGSURLToHTTPURL(gsURL: collectionImageURL2String)
                        let collectionImageURL3 = try await self.convertGSURLToHTTPURL(gsURL: collectionImageURL3String)
                        let collectionImageURL4 = try await self.convertGSURLToHTTPURL(gsURL: collectionImageURL4String)
                        
                        await self.fetchBookmarkStatus(title: title)
                        
                        return Card(title: title, description: description, longDescription1: longDescription1, longDescription2: longDescription2, imageURL: imageURL, shopAddress: shopAddress, queryName: queryName, collectionImageURL1: collectionImageURL1, collectionImageURL2: collectionImageURL2, collectionImageURL3: collectionImageURL3, collectionImageURL4: collectionImageURL4, order: order)
                    }
                }
                for try await card in taskGroup {
                    if let card = card {
                        fetchedCards.append(card)
                    }
                }
                return fetchedCards
            }
            
            DispatchQueue.main.async {
                self.cards = fetchedCards.sorted(by: { $0.order < $1.order })
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
            let query = bookmarkedCollection
                .whereField(db_uid, isEqualTo: uid)
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        bookmarkedCollection.addDocument(data: [db_title: title, db_imageURL: imageURL, db_uid: uid]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                self.isBookmarked = true
            }
        }
    }
    func deleteBookmarkItem(title: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        bookmarkedCollection
            .whereField(db_uid, isEqualTo: uid)
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


