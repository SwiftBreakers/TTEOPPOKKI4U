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

class MapViewController: UIViewController {
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.isZoomEnabled = true     // 줌 가능 여부
        map.isScrollEnabled = true   // 이동 가능 여부
        map.isPitchEnabled = true    // 각도 조절 가능 여부 (두 손가락으로 위/아래 슬라이드)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return map
    }()
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "장소, 지역"
        bar.searchTextField.backgroundColor = .clear
        bar.searchTextField.borderStyle = .none
        bar.clipsToBounds = true
        bar.layer.cornerRadius = 20
        return bar
    }()
    let barLabel: UILabel = {
        let label = UILabel()
        label.text = "의 근처 맛집을 찾아주세요."
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
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
        
        searchBar.delegate = self
    }
    
    func setConstraints() {
        [mapView, searchBar, barLabel, storeInfoView].forEach {
            self.view.addSubview($0)
        }
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(50)
        }
        
        barLabel.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar.snp.centerY)
            make.leading.equalTo(searchBar.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(40)
        }
        
        storeInfoView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func setMapView() {
        mapView.delegate = self
     
        // 위치 관리자 설정
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        // 위치 업데이트 시작
        findMyLocation()
        locationManager.startUpdatingLocation()
    }
    
    func findMyLocation() {
        guard locationManager.location != nil else { return }
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
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
    
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func searchLocation(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("Error searching for location: \(String(describing: error))")
                return
            }
            if let mapItem = response.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.centerMapOnLocation(location: location)
                
                // 기존 핀 제거
                let allAnnotations = self.mapView.annotations
                self.mapView.removeAnnotations(allAnnotations)
                
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
        mapView.addAnnotation(annotation)
    }
    
    private func getDistance(latitude: String, longitude: String) -> CLLocationDistance {
        let storeLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        let distance = userLocation.distance(from: storeLocation)
        return distance
    }
    
}


extension MapViewController: UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate  {
    // MARK: - searchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
            //print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            userLocation = location
            centerMapOnLocation(location: location)
            locationManager.stopUpdatingLocation() // 위치 업데이트 멈추기
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
            if view.annotation?.subtitle == "분식집" {
                view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)  // 선택되면 떡볶이pin 크기 키우기
                let distance = getDistance(latitude: store.y, longitude: store.x)
                storeInfoView.bind(title: store.placeName, address: store.addressName, isScrapped: false, rating: 4.5, reviews: 54, distance: distance.prettyDistance)
                storeInfoView.isHidden = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        storeInfoView.isHidden = true
        view.transform = CGAffineTransform.identity
    }

}



