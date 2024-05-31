//
//  MapViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation

class MapViewController: UIViewController {
    
    let mapView: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.isZoomEnabled = true     // 줌 가능 여부
        map.isScrollEnabled = true   // 이동 가능 여부
        map.isPitchEnabled = true    // 각도 조절 가능 여부 (두 손가락으로 위/아래 슬라이드)
        return map
    }()
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "장소"
        bar.searchTextField.backgroundColor = .clear
        bar.layer.cornerRadius = 20
        return bar
    }()
    let barLabel: UILabel = {
        let label = UILabel()
        label.text = "의 근처 맛집을 찾아주세요."
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        setMapView()
        
        searchBar.delegate = self
    }
    
    func setConstraints() {
        [mapView, searchBar, barLabel].forEach {
            self.view.addSubview($0)
        }
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.leading.equalToSuperview().offset(30)
            make.height.equalTo(50)
        }
        
        barLabel.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar.snp.centerY)
            make.leading.equalTo(searchBar.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(30)
        }
    }
    
    func setMapView() {
        mapView.delegate = self
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest
        
        // 위치 추적 권한 받기
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        // 위치 사용 시 사용자의 현재 위치를 표시
        mapView.showsUserLocation = true
        
        // 사용자 위치를 추적
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        
        // 위도, 경도 설정
        let centerLocation = CLLocationCoordinate2D(
            latitude: searchLocation.latitude,
            longitude: searchLocation.longtitude
        )
        
        // 지도에 표시할 범위
        let region = MKCoordinateRegion(
            center: centerLocation,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        
        // annotation (pin 설정)
        let annotation = MKPointAnnotation()
        //annotation.title = locationStruct.name
        annotation.coordinate = centerLocation
        
        // locationView 세팅
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation) {
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
            let coordinate = response.mapItems.first?.placemark.coordinate
            if let coordinate = coordinate {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                self.centerMapOnLocation(location: location)
            }
        }
    }
    
}


extension MapViewController: UISearchBarDelegate, MKMapViewDelegate, MKLocalSearchCompleterDelegate {
    // MARK: - searchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        searchLocation(query: keyword)
        NetworkManager.shared.fetchAPI(query: "\(keyword) 분식")
    }
}


