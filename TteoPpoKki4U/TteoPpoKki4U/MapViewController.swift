//
//  MapViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class MapViewController: UIViewController, PinStoreViewDelegate {
    
    let mapView = MapView()
    lazy var storeInfoView: PinStoreView = {
        let view = PinStoreView()
        view.isHidden = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocation: CLLocation = CLLocation()
    var storeList: [Document] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        setMapView()
        
        mapView.searchBar.delegate = self
        storeInfoView.delegate = self
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false        
    }
    
    func setConstraints() {
        [mapView, storeInfoView].forEach {
            self.view.addSubview($0)
        }
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        storeInfoView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func setMapView() {
        mapView.map.delegate = self
        
        // 위치 관리자 설정
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        // 위치 업데이트 시작
        findMyLocation()
        locationManager.startUpdatingLocation()
    }
    
    func findMyLocation() {
        centerMapOnLocation(location: userLocation)
        mapView.map.showsUserLocation = true
        mapView.map.setUserTrackingMode(.follow, animated: true)
    }
    
    func LocationAuthorization() {
        // 위치 업데이트
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            } else {
                print("Location services are not enabled or authorized.")
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.map.setRegion(coordinateRegion, animated: true)
    }
    
    func searchLocation(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for location: \(String(describing: error))")
                self.showMessage(title: "잘못된 지역명입니다.", message: "올바른 지역명 또는 장소명을 입력해 주세요.")
                return
            }
            if let mapItem = response.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.centerMapOnLocation(location: location)
                
                // 기존 핀 제거
                let allAnnotations = self.mapView.map.annotations
                self.mapView.map.removeAnnotations(allAnnotations)
                
                // 검색한 장소에 핀 추가
                self.addPin(at: location, title: query, isMainLocation: true)
                
                // 주변 분식집들 핀 추가
                DispatchQueue.main.async {
                    self.addNearbyStorePins()
                }
            }
        }
    }
    
    private func addNearbyStorePins() {
        for store in self.storeList {
            let latitude = CLLocationDegrees(store.y)!
            let longitude = CLLocationDegrees(store.x)!
            let storeLocation = CLLocation(latitude: latitude, longitude: longitude)
            self.addPin(at: storeLocation, title: store.placeName, isMainLocation: false)
        }
    }
    
    private func addPin(at location: CLLocation, title: String, isMainLocation: Bool) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = title
        annotation.subtitle = isMainLocation ? "검색한 장소" : "분식집"
        mapView.map.addAnnotation(annotation)
    }
    
    private func getDistance(latitude: String, longitude: String) -> CLLocationDistance {
        let storeLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        let distance = userLocation.distance(from: storeLocation)
        return distance
    }
    
    // MARK: - firebase 데이터 관리
    func fetchScrapStatus(shopName: String, completion: @escaping (Bool) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        scrappedCollection
            .whereField(db_uid, isEqualTo: userID)
            .whereField(db_shopName, isEqualTo: shopName)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
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
    
    func createScrapItem(shopName: String, shopAddress: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        scrappedCollection.addDocument(data: [db_shopName: shopName, db_shopAddress: shopAddress, db_uid: userID]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            }
        }
    }
    
    func deleteScrapItem(shopName: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        scrappedCollection
            .whereField(db_uid, isEqualTo: userID)
            .whereField(db_shopName, isEqualTo: shopName)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        scrappedCollection.document(document.documentID).delete() { error in
                            if let error = error {
                                print("Error removing document: \(error)")
                            }
                        }
                    }
                }
            }
    }
    
    func pinStoreViewDidTapScrapButton(_ view: PinStoreView) {
        if self.storeInfoView.isScrapped {
            // 이미 스크랩된 상태 -> 스크랩 해제
            deleteScrapItem(shopName: view.titleLabel.text!)
            self.storeInfoView.isScrapped.toggle()
        } else {
            // 스크랩되지 않은 상태 -> 스크랩 추가
            createScrapItem(shopName: view.titleLabel.text!, shopAddress: view.addressLabel.text!)
            self.storeInfoView.isScrapped.toggle()
        }
    }
    
    func fetchRatings(for storeName: String, completion: @escaping ([Float]?, Error?) -> Void) {
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
    
    func getAverageRating(ratings: [Float]) -> Float {
        let count = ratings.count
        var sum:Float = 0.0
        
        for rating in ratings {
            sum += rating
        }
        if count == 0 {
            return 0.0
        } else {
            return sum / Float(count)
        }
    }
    
}


extension MapViewController: UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate  {
    // MARK: - searchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mapView.searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mapView.searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        NetworkManager.shared.fetchAPI(query: "\(keyword) 분식") { [weak self] stores in
            self?.storeList = stores
            
            // 데이터 수신 후 검색 위치 업데이트
            DispatchQueue.main.async {
                self?.LocationAuthorization()
                self?.searchLocation(query: keyword)
            }
        }
    }
    
    // MARK: - locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            centerMapOnLocation(location: location)
            locationManager.stopUpdatingLocation()  // 위치 업데이트 멈추기
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - mapview
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "CustomPinAnnotationView"
        
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        if annotation is MKUserLocation { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = false
        } else {
            annotationView?.annotation = annotation
        }
        
        if annotation.subtitle == "검색한 장소" {
            annotationView?.image = UIImage(named: "mainPin")
        } else {
            annotationView?.image = UIImage(named: "pin")
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        if let store = storeList.first(where: { $0.placeName == annotation.title }) {
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)    // 선택되면 떡볶이pin 크기 키우기
            
            self.fetchScrapStatus(shopName: store.placeName) { isScrapped in             // scrap 여부 구하기
                let distance = self.getDistance(latitude: store.y, longitude: store.x)   // 거리 구하기
                
                self.fetchRatings(for: store.placeName) { (ratings, error) in            // rating, reviews 구하기
                    if let error = error {
                        print("Error getting ratings: \(error)")
                    } else {
                        guard let ratings = ratings else { return }
                        let averageRating = self.getAverageRating(ratings: ratings)
                        
                        self.storeInfoView.bind(title: store.placeName, address: store.addressName, isScrapped: isScrapped, rating: averageRating, reviews: ratings.count, distance: distance.prettyDistance)
                        self.storeInfoView.isHidden = false
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        storeInfoView.isHidden = true
        view.transform = CGAffineTransform.identity
    }
    
}
