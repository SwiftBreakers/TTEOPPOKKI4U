//
//  DetailViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/05.
//
import UIKit
import SnapKit

class DetailViewController: UIViewController {
    
    var card: Card?
    
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let longDescriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureView()
    }
    
    private func configureView() {
        guard let card = card else { return }
        titleLabel.text = card.title
        descriptionLabel.text = card.description
        longDescriptionLabel.text = card.longDescription
        imageView.image = card.image
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // 이미지뷰 설정
        imageView.contentMode = .scaleAspectFit
        
        // 타이틀 라벨 설정
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        // 설명 라벨 설정
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        longDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        longDescriptionLabel.numberOfLines = 100
        longDescriptionLabel.textAlignment = .left
        
        // 서브뷰 추가
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(longDescriptionLabel)
        
        // SnapKit으로 오토레이아웃 설정
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)
        }
        longDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.top).inset(30)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
}
