//
//  MapViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import MapKit
import SnapKit

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
    }
    
    func setConstraints() {
        [mapView, searchBar, barLabel].forEach {
            self.view.addSubview($0)
        }
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.leading.equalToSuperview().offset(30)
        }
        
        barLabel.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar.snp.centerY)
            make.leading.equalTo(searchBar.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(30)

        }
    }


}
