//
//  JsonViewModel.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/26/24.
//

import Foundation
import CoreLocation

class JsonViewModel {
    private let jsonService: JsonService
    
    init(jsonService: JsonService) {
        self.jsonService = jsonService
    }
    
    func getNearbyStores(currentLocation: CLLocation, within distance: Double = 250) -> [JsonModel] {
        return jsonService.filterStores(within: distance, from: currentLocation)
    }
}
