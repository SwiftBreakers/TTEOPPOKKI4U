//
//  PinStoreView.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 6/4/24.
//

import UIKit
import SnapKit
import FirebaseAuth

class PinStoreView: UIView {
    
    weak var delegate: PinStoreViewDelegate?
    
    var isScrapped = false {
        didSet {
            if isScrapped {
                scrapButton.backgroundColor = ThemeColor.mainOrange
                scrapButton.tintColor = .white
                scrapButton.layer.borderWidth = 0
            } else {
                scrapButton.backgroundColor = .white
                scrapButton.tintColor = .black
                scrapButton.layer.borderWidth = 1
            }
        }
    }
    var callNumberText: String?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontBold(size: 22)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    lazy var scrapButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 12
        bt.layer.borderWidth = 1
        bt.setImage(UIImage(systemName: "flag"), for: .normal)
        return bt
    }()
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular()
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textColor = .darkGray
        return label
    }()
    lazy var reviewsLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textColor = .darkGray
        return label
    }()
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontRegular(size: 14)
        label.textColor = .darkGray
        return label
    }()
    let stackView: UIStackView = {
        let stv = UIStackView()
        stv.axis = .horizontal
        stv.distribution = .equalSpacing
        return stv
    }()
    let findFriendButton: UIButton = {
        let bt = UIButton()
        bt.setTitle("친구 찾기", for: .normal)
        bt.setTitleColor(.white, for: .normal)
        bt.titleLabel?.font = ThemeFont.fontBold(size: 16)
        bt.titleLabel?.textAlignment = .center
        bt.backgroundColor = ThemeColor.mainOrange
        bt.layer.cornerRadius = 8
        return bt
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        setConstraints()
        setClickEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setConstraints() {
        [ratingLabel, reviewsLabel, distanceLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [titleLabel, scrapButton, addressLabel, line, stackView, findFriendButton].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        scrapButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.verticalEdges.equalTo(titleLabel.snp.verticalEdges)
            make.width.equalTo(self.scrapButton.snp.height)
            make.leading.equalTo(titleLabel.snp.trailing).inset(-10)
            make.trailing.equalToSuperview().inset(20)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().inset(20)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(line.snp.horizontalEdges).inset(5)
            //make.bottom.equalToSuperview().inset(20)   // 친구찾기 버튼 복구 시 삭제하기
        }
        
        findFriendButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(15)
            make.horizontalEdges.bottom.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
    }
    
    private func setClickEvents() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tapGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(titleLabelTapped))
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(tap)
        
        scrapButton.addTarget(self, action: #selector(scrapButtonTapped), for: .touchUpInside)
        findFriendButton.addTarget(self, action: #selector(findFriendsButtonTapped), for: .touchUpInside)
    }
    
    // uilabel 텍스트 앞에 아이콘 넣기
    func makeIconBeforeText(icon: String, label: String) -> NSMutableAttributedString {
        let iconImage = UIImage(systemName: icon)?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        let attachment = NSTextAttachment()
        attachment.image = iconImage
        attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
        
        // 이미지와 텍스트 결합
        let iconString = NSAttributedString(attachment: attachment)
        let textString = NSAttributedString(string: label)
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(iconString)
        mutableAttributedString.append(textString)
        
        return mutableAttributedString
    }
    
    func bind(title: String, address: String, isScrapped: Bool, rating: Float, reviews: Int, distance: String, callNumber: String) {
        let formattedRating = String(format: "%.1f", rating)
        
        titleLabel.text = title
        addressLabel.text = address
        self.isScrapped = isScrapped
        ratingLabel.attributedText = makeIconBeforeText(icon: "star", label: formattedRating)
        reviewsLabel.attributedText = makeIconBeforeText(icon: "text.bubble", label: " \(reviews)개")
        distanceLabel.attributedText = makeIconBeforeText(icon: "arrow.turn.down.right", label: distance)
        self.callNumberText = callNumber
    }
    
    @objc func titleLabelTapped() {
        let storeVC = StoreViewController()
        guard let address = addressLabel.text, let shopName = titleLabel.text else { return }
        storeVC.addressText = address
        storeVC.shopTitleText = shopName
        storeVC.callNumberText = self.callNumberText
    
        currentViewController?.navigationController?.pushViewController(storeVC, animated: true)
    }
    
    @objc func scrapButtonTapped() {
        delegate?.scrapButtonTapped(self)
    }
    
    @objc func findFriendsButtonTapped() {
        guard let regionSubSequence = addressLabel.text?.split(separator: " ").first else { return }
        let region = String(regionSubSequence)
        let channelName = getChannelName(address: region)
        
        let chatVC: ChatVC
        chatVC = ChatVC(user: Auth.auth().currentUser!, channel: Channel(name: channelName))
        chatVC.isLocation = true
        currentViewController?.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func getChannelName(address: String) -> String {
            switch address {
            case "서울":
                return "서울특별시"
            case "경기":
                return "경기도"
            case "강원특별자치도":
                return "강원도"
            case "충북":
                return "충청북도"
            case "충남":
                return "충청남도"
            case "경북":
                return "경상북도"
            case "경남":
                return "경상남도"
            case "전북":
                return "전라북도"
            case "전남":
                return "전라남도"
            case "광주":
                return "광주광역시"
            case "대구":
                return "대구광역시"
            case "대전":
                return "대전광역시"
            case "부산":
                return "부산광역시"
            case "울산":
                return "울산광역시"
            case "세종특별자치시":
                return "세종특별자치시"
            case "제주특별자치도":
                return "제주특별자치도"
            default:
                return "default"
            }
        }
}


protocol PinStoreViewDelegate: AnyObject {
    func scrapButtonTapped(_ view: PinStoreView)
}
