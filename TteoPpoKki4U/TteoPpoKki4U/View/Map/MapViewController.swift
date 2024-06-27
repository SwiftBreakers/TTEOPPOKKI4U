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

protocol MapViewControllerDelegate: AnyObject {
    func didSelectLocation(_ location: CLLocationCoordinate2D)
}

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
    weak var delegate: MapViewControllerDelegate?
    var selectedLocation: CLLocationCoordinate2D?
    var selectedStoreName: String?
    private var viewModel = MapViewModel()
    private var jsonViewModel: JsonViewModel!
    var isLocationPicker: Bool = false
    var selectedStoreRatings = [Float]()
    var selectedStoreAverageRating: Float?
    var isSelectedStoreScrapped: Bool = false
    private var currentAddress = ""
    private var jsonFileName = ""
    private var isSearched = false
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .gray
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .gray
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setConstraints()
        setMapView()
        setClickEvents()
        
        mapView.searchBar.delegate = self
        storeInfoView.delegate = self
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        mapView.map.addGestureRecognizer(longPressGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        if isLocationPicker {
            setupButtons()
        }
        getRecentData()
    }
    
    private func loadJson(file name: String) {
        let allAnnotations = self.mapView.map.annotations
        self.mapView.map.removeAnnotations(allAnnotations)
        
        let jsonService = JsonService(fileName: name)
        jsonViewModel = JsonViewModel(jsonService: jsonService)
        
        let nearStores = jsonViewModel.getNearbyStores(currentLocation: userLocation)
        viewModel.loadJsonStores(nearStores)
        
        addNearbyStorePins(for: nearStores)
    }
    
    private func getFileName(address: String) -> String {
            switch address {
            case "서울특별시":
                return "seoul"
            case "경기도":
                return "gyeonggi"
            case "인천광역시":
                return "incheon"
            case "강원도":
                return "kangwon"
            case "충청북도":
                return "chungbuk"
            case "충청남도":
                return "chungnam"
            case "경상북도":
                return "kyeongbuk"
            case "경상남도":
                return "gyeongnam"
            case "전라북도":
                return "jeonbuk"
            case "전라남도":
                return "jeonnam"
            case "광주광역시":
                return "kwangju"
            case "대구광역시":
                return "daegu"
            case "대전광역시":
                return "daejeon"
            case "부산광역시":
                return "pusan"
            case "울산광역시":
                return "ulsan"
            case "세종특별자치시":
                return "sejong"
            case "제주특별자치도":
                return "jeju"
            default:
                return "default"
            }
        }
    
    private func getRecentData() {
        if selectedStoreName != nil {
            Task {
                await
                selectedStoreRatings = viewModel.getRatings(for:selectedStoreName!)
                selectedStoreAverageRating = viewModel.getAverageRating(ratings: selectedStoreRatings)
                isSelectedStoreScrapped = await viewModel.getScrap(for:selectedStoreName!)
                let formattedRating = String(format: "%.1f", selectedStoreAverageRating!)
                storeInfoView.ratingLabel.attributedText = storeInfoView.makeIconBeforeText(icon: "star", label: formattedRating)
                storeInfoView.reviewsLabel.attributedText = storeInfoView.makeIconBeforeText(icon: "text.bubble", label: " \(selectedStoreRatings.count)개")
                storeInfoView.isScrapped = isSelectedStoreScrapped
            }
        }
    }
    
    private func displayStoreInfoFromJSON(with name: String) {
        // JsonViewModel을 통해 JSON 데이터를 가져옴
        let stores = jsonViewModel.getNearbyStores(currentLocation: userLocation)
        
        // 이름에 해당하는 스토어를 찾음
        if let store = stores.first(where: { $0.storeName == name }) {
            Task {
                let ratings = await viewModel.getRatings(for: store.storeName)
                let isScrapped = await viewModel.getScrap(for: store.storeName)
                let averageRating = getAverageRating(ratings: ratings)
                DispatchQueue.main.async { [weak self] in
                    self?.storeInfoView.bind(
                        title: store.storeName,
                        address: store.address,
                        isScrapped: isScrapped,
                        rating: averageRating,
                        reviews: ratings.count,
                        distance: (self?.getDistance(with: store.y, store.x).prettyDistance)!,
                        callNumber: ""
                    )
                    self?.storeInfoView.isHidden = false
                }
            }
        }
    }
    
    private func getAverageRating(ratings: [Float]) -> Float {
        let count = ratings.count
        guard count > 0 else { return 0.0 }
        
        let sum = ratings.reduce(0, +)
        return sum / Float(count)
    }
    
    private func addNearbyStorePins(for stores: [JsonModel]) {
        for store in stores {
            let latitude = CLLocationDegrees(store.y)
            let longitude = CLLocationDegrees(store.x)
            let storeLocation = CLLocation(latitude: latitude, longitude: longitude)
            self.addPin(at: storeLocation, title: store.storeName, isMainLocation: false)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
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
    
    private func setupButtons() {
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(sendButton)
        
        buttonStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
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
                self.isSearched = true
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
        getAddress(coordinate: userLocation)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView.map)
            let coordinate = mapView.map.convert(touchPoint, toCoordinateFrom: mapView.map)
            selectedLocation = coordinate
            
            // 기존 핀 제거
            let allAnnotations = mapView.map.annotations
            mapView.map.removeAnnotations(allAnnotations)
            
            // 새로운 핀 추가
            addPin(at: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), title: "선택된 위치", isMainLocation: true)
        }
    }

    @objc func sendButtonTapped() {
        if let location = selectedLocation {
            delegate?.didSelectLocation(location)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
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
                    distance: getDistance(with: store.latitude, store.longitude).prettyDistance,
                    callNumber: store.callNumber
                )
                self.storeInfoView.isHidden = false
                
            case let .didLoadedWithError(error):
                // do something with error
                print(error)
                if error == .noUID {
                    DispatchQueue.main.async {
                        self.showMessage(title: "안내", message: "로그인이 필요한 기능입니다.") {
                            let scene = UIApplication.shared.connectedScenes.first
                            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                                sd.switchToGreetingViewController()
                            }
                        }
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
            getAddress(coordinate: location)
            locationManager.stopUpdatingLocation()  // 위치 업데이트 멈추기
        }
    }
    
    func getAddress(coordinate: CLLocation) {
        let address = CLGeocoder.init()
        
        address.reverseGeocodeLocation(coordinate) { [weak self] (placeMarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placeMarks?[0]
            
            guard let address = placeMark else { return }
            self?.currentAddress = address.administrativeArea!
            self?.jsonFileName = (self?.getFileName(address: self!.currentAddress))!
            self?.loadJson(file: self!.jsonFileName)
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
        if isSearched == true {
            viewModel.loadStore(with: name)
        } else {
            displayStoreInfoFromJSON(with: name)
        }
        selectedStoreName = name
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        storeInfoView.isHidden = true
        view.transform = CGAffineTransform.identity
    }
    
}
