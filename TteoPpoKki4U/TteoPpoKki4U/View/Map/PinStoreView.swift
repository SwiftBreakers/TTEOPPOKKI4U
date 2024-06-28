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
    
    let userManager = UserManager()
    var currentName: String?
    
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
        let channelInfo = getChannelInfo(address: region)
        
        if let user = Auth.auth().currentUser {
            
            checkNickname(uid: user.uid) { [weak self] result in
                switch result {
                case true :
                    let chatVC = ChatVC(user: user, channel: Channel(id: channelInfo.id, name: channelInfo.name))
                    chatVC.isLocation = true
                    self?.currentViewController?.navigationController?.pushViewController(chatVC, animated: true)
                case false :
                    self?.currentViewController?.showMessage(title: "안내", message: "닉네임 설정을 먼저 해주세요.")
                }
            }

        } else {
            currentViewController?.showMessageWithCancel(title: "로그인이 필요한 기능입니다.", message: "확인을 클릭하시면 로그인 페이지로 이동합니다.") {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.switchToGreetingViewController()
                }
            }
        }
    }
    
    private func getChannelInfo(address: String) -> (id: String, name: String) {
        switch address {
        case "서울":
            return ("rHab49QfIiTU2g59iOho", "서울특별시")
        case "경기":
            return ("4ZfnmRzimiBAqi9yevHs", "경기도")
        case "강원특별자치도":
            return ("AzvAnfWm3H26tBiWVD0n", "강원도")
        case "충북":
            return ("42dFCDyZhoF5HsZiGHiR", "충청북도")
        case "충남":
            return ("JqmZpJgXPJSDYrKmQS8Z", "충청남도")
        case "경북":
            return ("ur4UAL6hG5vCJSQCwNDj", "경상북도")
        case "경남":
            return ("wiBr0aYzdyvI3QOR8iZp", "경상남도")
        case "전북":
            return ("rufxIoaIPAqLs197P3RP", "전라북도")
        case "전남":
            return ("EsKtN3g6LoRfOIuPoNVh", "전라남도")
        case "광주":
            return ("KnchGwEEDQQ0hV6bQM5i", "광주광역시")
        case "대구":
            return ("SuOKtqriajsOPcPBvewm", "대구광역시")
        case "대전":
            return ("88EulHa6KF4LChqeUgMY", "대전광역시")
        case "부산":
            return ("h6xTcrUCBHUc9KvCwcxk", "부산광역시")
        case "울산":
            return ("kIpkkRqgmj9KOqwBGL81", "울산광역시")
        case "세종특별자치시":
            return ("TbKkSzKgPNHEBbWspSCp", "세종특별자치시")
        case "제주특별자치도":
            return ("CxoT9A2FwnypYLJNeZ5P", "제주특별자치도")
        default:
            return ("defaultID", "default")
        }
    }
    
    private func checkNickname(uid: String, completion: @escaping(Bool) -> Void) {

        userManager.fetchUserData(uid: uid) { [self] error, snapshot in
            if let error = error {
                print(error)
            }
            guard let dictionary = snapshot?.value as? [String: Any] else { return }
            currentName = (dictionary[db_nickName] as? String) ?? "Unknown"
            print(currentName!)
            if currentName! == ""  {
                completion(false)
            } else {
                completion(true)
            }
        }

    }
    
}


protocol PinStoreViewDelegate: AnyObject {
    func scrapButtonTapped(_ view: PinStoreView)
}
