//
//  MapViewController.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 5/28/24.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation

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
    
    private var viewModel = MapViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        setMapView()
        setClickEvents()
        bind()
        
        mapView.searchBar.delegate = self
        storeInfoView.delegate = self
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
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
    
    private func setMapView() {
        mapView.map.delegate = self
        
        // 위치 관리자 설정
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        // 위치 업데이트 시작
        findMyLocation()
        locationManager.startUpdatingLocation()
    }
    
    private func setClickEvents() {
        mapView.findMyLocationBtn.addTarget(self, action: #selector(findMyLocationBtnTapped), for: .touchUpInside)
    }
    
    private func findMyLocation() {
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
        let regionRadius: CLLocationDistance = 700
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        mapView.map.setRegion(coordinateRegion, animated: true)
    }
    
    func searchLocation(query: String, for stores: [Document]) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response else {
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
                    self.addNearbyStorePins(for: stores)
                }
            }
        }
    }
    
    private func addNearbyStorePins(for stores: [Document]) {
        for store in stores {
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
    
    @objc func appWillEnterForeground() {
        updatePinImages()
    }
    
    func updatePinImages() {
        for annotation in mapView.map.annotations {
            if let annotationView = mapView.map.view(for: annotation) as? MKPinAnnotationView {
                if annotation.subtitle == "검색한 장소" {
                    annotationView.image = UIImage(named: "mainPin")
                } else {
                    annotationView.image = UIImage(named: "pin")
                }
            }
        }
        
    }
    
    func scrapButtonTapped(_ view: PinStoreView) {
        let name = view.titleLabel.text ?? ""
        viewModel.scrap(name, upon: storeInfoView.isScrapped)
        storeInfoView.isScrapped.toggle()
    }
    
    @objc func findMyLocationBtnTapped() {
        findMyLocation()
    }
    
    private func getDistance(with latitude: Double, _ longitude: Double) -> CLLocationDistance {
        let storeLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = userLocation.distance(from: storeLocation)
        return distance
    }

    private func bind() {
        viewModel.didChangeState = { [weak self] viewModel in
            guard let self else { return }
            
            switch viewModel.state {
            case let .didStoresLoaded(keyword, stores):
                DispatchQueue.main.async {
                    self.LocationAuthorization()
                    self.searchLocation(query: keyword, for: stores)
                }
                
            case let .didLoadedStore(store):
                storeInfoView.bind(
                    title: store.title,
                    address: store.address,
                    isScrapped: store.isScrapped,
                    rating: store.rating,
                    reviews: store.reviews,
                    distance: getDistance(with: store.latitude, store.longitude).prettyDistance
                )
                self.storeInfoView.isHidden = false
                
            case let .didLoadedWithError(error):
                // do something with error
                print(error)
                if error == .noUID {
                    DispatchQueue.main.async { 
                        self.showMessage(title: "안내", message: "로그인이 필요한 기능입니다.")
                        self.storeInfoView.isScrapped = false
                    }
                }
                
            default: break
            }
        }
    }
    
}


extension MapViewController: UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate  {
    // MARK: - searchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mapView.searchBar.resignFirstResponder()
        guard let keyword = searchBar.text else { return }
        viewModel.loadStores(with: keyword)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mapView.searchBar.resignFirstResponder()
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
        guard let annotation = view.annotation,
              let name = annotation.title ?? "",
              !name.isEmpty
        else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        })
        viewModel.loadStore(with: name)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        storeInfoView.isHidden = true
        view.transform = CGAffineTransform.identity
    }
    
}
