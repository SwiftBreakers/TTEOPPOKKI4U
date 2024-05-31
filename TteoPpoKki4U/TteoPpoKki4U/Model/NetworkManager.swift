//
//  NetworkManager.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 5/30/24.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    
    func fetchAPI(query: String) {
        
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword")!
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "category_group_code", value: "FD6"),
            //URLQueryItem(name: "radius", value: "200")
        ]
        
        // URL 구성 요소를 사용하여 URL 생성
        guard let url = components.url else {
            print("Failed to create URL")
            return
        }
        print(url)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.allHTTPHeaderFields = ["Authorization" : "KakaoAK 32b459e18e4f795d25e65e31ec0da140"]
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            // 응답 코드가 성공(200)인지 확인
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response code: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            let stores = try? JSONDecoder().decode(Welcome.self, from: data)
            print(stores)
        }.resume()
    }
}
