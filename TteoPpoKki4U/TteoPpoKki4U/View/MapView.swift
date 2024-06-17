//
//  MapView.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 5/29/24.
//

import Foundation
import MapKit

class MapView: UIView {
    
    let map: MKMapView = {
        let map = MKMapView()
        map.mapType = .standard
        map.isZoomEnabled = true     // 줌 가능 여부
        map.isScrollEnabled = true   // 이동 가능 여부
        map.isPitchEnabled = true    // 각도 조절 가능 여부 (두 손가락으로 위/아래 슬라이드)
        map.showsCompass = false
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return map
    }()
    let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.backgroundColor = .white
        bar.barTintColor = .white
        bar.searchTextField.attributedPlaceholder = NSAttributedString(string: "장소명 또는 지역명을 입력해 주세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        bar.searchTextField.leftView?.tintColor = .gray
        bar.searchTextField.textColor = .black
        bar.searchTextField.borderStyle = .none
        bar.searchTextField.backgroundColor = .white
        bar.clipsToBounds = true
        bar.layer.cornerRadius = 20
        return bar
    }()
    lazy var compassBtn: MKCompassButton = {
        let btn = MKCompassButton(mapView: map)
        btn.frame.origin = CGPoint(x: self.frame.maxX - 40, y: 20)
        btn.compassVisibility = .adaptive
        return btn
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setConstraints() {
        [map, searchBar, compassBtn].forEach {
            self.addSubview($0)
        }
        
        map.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(50)
        }
        
        compassBtn.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
    }
}

