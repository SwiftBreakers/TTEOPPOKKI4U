//
//  NetworkManager.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 5/30/24.
//

import Foundation

class NetworkManager {
    
    func fetchAPI(query: String) {
        
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/geo/transcoord")!
        components.queryItems = [
            URLQueryItem(name: "query", value: "엽떡"),
            URLQueryItem(name: "category_group_code", value: "FD6"),
        ]
        
        // URL 구성 요소를 사용하여 URL 생성
        guard let url = components.url else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            print("data: ", data)
            print("response: ", response)
            print("error: ", error)
        }.resume()
    }
}
