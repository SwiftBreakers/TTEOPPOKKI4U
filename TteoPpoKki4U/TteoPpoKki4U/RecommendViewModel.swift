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
            
            // 각 document에 대해 비동기 작업을 병렬로 처리
            let cards = try await withThrowingTaskGroup(of: Card?.self) { taskGroup in
                for document in querySnapshot.documents {
                    taskGroup.addTask {
                        let data = document.data()
                        
                        let title = data["title"] as? String ?? "No Title"
                        let description = data["description"] as? String ?? "No Description"
                        let imageURL = data["imageURL"] as? String ?? ""
                        let longDescription = data["longDescription"] as? String ?? "No LongDescription"
                        var card = Card(title: title, description: description, imageURL: imageURL, longDescription: longDescription)
                        
                        // 이미지를 비동기적으로 가져옴
                        if let image = await self.fetchImage(for: card) {
                            card.image = image
                        }
                        return card
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
    
    private func fetchImage(for card: Card) async -> UIImage? {
        guard card.imageURL.starts(with: "gs://") else {
            print("Invalid URL scheme: \(card.imageURL)")
            return nil
        }
        
        do {
            print("Fetching image for URL: \(card.imageURL)")
            let reference = storage.reference(forURL: card.imageURL)
            let url = try await reference.downloadURL()
            print("Fetched download URL: \(url)")
            let data = try await downloadImageData(from: url)
            print("Fetched image data")
            return UIImage(data: data)
        } catch {
            print("Error fetching image: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func downloadImageData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Response Status Code: \(httpResponse.statusCode)")
        }
        return data
    }
    
    public func card(at index: Int) -> Card {
        return cards[index]
    }
}


