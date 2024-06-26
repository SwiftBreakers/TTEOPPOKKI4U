//
//  JsonService.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/25/24.
//

import Foundation
import CoreLocation

class JsonService {
    private var stores: [JsonModel] = []
    
    init(fileName: String) {
        loadJSON(fileName: fileName)
    }
    
    private func loadJSON(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Error: File not found")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            stores = try JSONDecoder().decode([JsonModel].self, from: data)
        } catch {
            print("Error loading JSON: \(error)")
        }
    }
    
    func getStores() -> [JsonModel] {
        return stores
    }
    
    func filterStores(within distance: Double, from currentLocation: CLLocation) -> [JsonModel] {
        return stores.filter { store in
            let storeLocation = CLLocation(latitude: store.y, longitude: store.x)
            let distanceFromCurrentLocation = currentLocation.distance(from: storeLocation)
            return distanceFromCurrentLocation <= distance
        }
    }
}
