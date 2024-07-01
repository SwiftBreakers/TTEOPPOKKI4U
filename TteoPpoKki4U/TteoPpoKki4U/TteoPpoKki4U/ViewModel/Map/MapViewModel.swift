//
//  MapVIewModel.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 5/29/24.
//

import Foundation
import FirebaseAuth

final class MapViewModel {
    private var stores: [Document] = [] // 검색시 가져오는 데이터
    private var jsonStores: [JsonModel] = [] // json에서 가져오는 데이터
    
    private(set) var state: State = .pending {
        didSet { didChangeState?(self) }
    }
    
    enum State {
        case pending
        case didStoresLoaded(forKeyword: String, stores: [Document])
        case didLoadedStore(store: ShopView)
        case didLoadedWithError(error: StoreError)
    }
    
    enum StoreError: Error {
        case noStore
        case noUID
    }
    
    var didChangeState: ((MapViewModel) -> Void)?
    
    func loadStores(with name: String) {
        NetworkManager.shared.fetchAPI(query: "\(name) 분식") { [weak self] stores in
            self?.stores = stores
            self?.state = .didStoresLoaded(forKeyword: name, stores: stores)
        }
    }
    
    func loadJsonStores(_ stores: [JsonModel]) {
        self.jsonStores = stores
    }
    
    func loadStore(with name: String) {
        
        if let store = findStore(with: name) {
                let storeName = store.placeName
                Task {
                    async let isScrapped = getScrap(for: storeName)
                    async let ratings = getRatings(for: storeName)
                    let presentable = await ShopView(
                        title: storeName,
                        address: store.roadAddressName,
                        rating: getAverageRating(ratings: ratings),
                        reviews: ratings.count,
                        latitude: Double(store.y) ?? 0.0,
                        longitude: Double(store.x) ?? 0.0,
                        isScrapped: isScrapped,
                        callNumber: store.phone == "" ? "가게 번호 없음" : store.phone
                    )
                    await MainActor.run {
                        state = .didLoadedStore(store: presentable)
                    }
                }
            } else if let store = findJsonStore(with: name) {
                // JSON store
                Task {
                    let presentable = ShopView(
                        title: store.storeName,
                        address: store.address,
                        rating: 0.0,
                        reviews: 0,
                        latitude: store.y,
                        longitude: store.x,
                        isScrapped: false,
                        callNumber: "" // JSON 데이터에서 전화번호를 제공하지 않는다고 가정
                    )
                    await MainActor.run {
                        state = .didLoadedStore(store: presentable)
                    }
                }
            }
//        fetchScrapStatus(shopName: storeName) { [weak self] isScrapped in
//            guard let self else { return }
//            fetchRatings(for: storeName) { (ratings, error) in
//                guard let ratings, error == nil else { return }
//                let averageRating = self.getAverageRating(ratings: ratings)
//                let presentable = ShopViewPresentable(
//                    title: storeName,
//                    address: store.addressName,
//                    rating: self.getAverageRating(ratings: ratings),
//                    reviews: ratings.count,
//                    latitude: Double(store.x) ?? 0.0,
//                    longitude: Double(store.y) ?? 0.0,
//                    isScrapped: isScrapped
//                )
//                self.state = .didLoadedStore(store: presentable)
//            }
//        }
    }
    
    func getScrap(for storeName: String) async -> Bool {
        await withCheckedContinuation { continuation in
            fetchScrapStatus(shopName: storeName) {
                continuation.resume(returning: $0)
            }
        }
    }
    
    func getRatings(for storeName: String) async -> [Float] {
        await withCheckedContinuation { continuation in
            fetchRatings(for: storeName) { ratings, error in
                guard let ratings, error == nil else { return }
                continuation.resume(returning: ratings)
            }
        }
    }
    
    func scrap(_ storeName: String, upon isAlreadyScrapped: Bool) {
        if let store = findStore(with: storeName) {
            isAlreadyScrapped ? undoScrap(store) : scrap(store)
        } else if let store = findJsonStore(with: storeName) {
            isAlreadyScrapped ? undoScrapJsonStore(store) : scrapJsonStore(store)
        }
    }
    
    // MARK: - Helpers
    
    private func scrap(_ store: Document) {
        createScrapItem(shopName: store.placeName, shopAddress: store.roadAddressName)
    }
    
    private func undoScrap(_ store: Document) {
        deleteScrapItem(shopName: store.placeName)
    }
    
    private func findStore(with name: String) -> Document? {
        stores.first { $0.placeName == name }
    }
    
    func getAverageRating(ratings: [Float]) -> Float {
        let count = ratings.count
        var sum: Float = 0.0
        
        for rating in ratings {
            sum += rating
        }
        if count == 0 {
            return 0.0
        } else {
            return sum / Float(count)
        }
    }
    
    private func createScrapItem(shopName: String, shopAddress: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            self.state = .didLoadedWithError(error: .noUID)
            return }
        scrappedCollection.addDocument(
            data: [
                db_shopName: shopName,
                db_shopAddress: shopAddress,
                db_uid: userID
            ]
        ) { error in
            if let error {
                print("Error adding document: \(error)")
            }
        }
    }
    
    private func deleteScrapItem(shopName: String) {
        guard let userID = Auth.auth().currentUser?.uid else { 
            self.state = .didLoadedWithError(error: .noUID)
            return }
        
        scrappedCollection
            .whereField(db_uid, isEqualTo: userID)
            .whereField(db_shopName, isEqualTo: shopName)
            .getDocuments { (querySnapshot, error) in
                if let error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        scrappedCollection.document(document.documentID).delete() { error in
                            if let error {
                                print("Error removing document: \(error)")
                            }
                        }
                    }
                }
            }
    }
    
    private func fetchScrapStatus(shopName: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { 
            completion(false)
            return }
        scrappedCollection
            .whereField(db_uid, isEqualTo: userID)
            .whereField(db_shopName, isEqualTo: shopName)
            .getDocuments { (querySnapshot, error) in
                if let error {
                    print("Error getting documents: \(error)")
                    completion(false)
                } else {
                    if let documents = querySnapshot?.documents, !documents.isEmpty {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
    }
    
    private func fetchRatings(for storeName: String, completion: @escaping ([Float]?, Error?) -> Void) {
        reviewCollection
            .whereField(db_storeName, isEqualTo: storeName)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(nil, error)
                } else {
                    var ratings: [Float] = []
                    for document in querySnapshot!.documents {
                        if let rating = document.get(db_rating) as? Float {
                            ratings.append(rating)
                        }
                    }
                    completion(ratings, nil)
                }
            }
    }
    
    // JSON 스토어 찾는 메서드
    private func findJsonStore(with name: String) -> JsonModel? {
        return jsonStores.first { $0.storeName == name }
    }

    private func scrapJsonStore(_ store: JsonModel) {
        createScrapItem(shopName: store.storeName, shopAddress: store.address)
    }

    private func undoScrapJsonStore(_ store: JsonModel) {
        deleteScrapItem(shopName: store.storeName)
    }
}
