//
//  PinStoreView.swift
//  TteoPpoKki4U
//
//  Created by 박준영 on 6/4/24.
//

import UIKit
import SnapKit

class PinStoreView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: ThemeFont.fontMedium, size: 24)
        return label
    }()
    let scrapButton: UIButton = {
        let bt = UIButton()
        bt.layer.cornerRadius = 20
        bt.setImage(UIImage(systemName: "flag"), for: .normal)
        bt.setTitleColor(.black, for: .normal)
        bt.setTitleColor(ThemeColor.mainOrange, for: .highlighted)
        return bt
    }()
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: ThemeFont.fontRegular, size: 18)
        return label
    }()
    let line: UIView = {
        let view = UIView()
        view.frame.size.height = 1
        return view
    }()
    lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: ThemeFont.fontRegular, size: 14)
        label.attributedText = makeIconBeforeText(icon: "star")
        return label
    }()
    lazy var reviewsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: ThemeFont.fontRegular, size: 14)
        label.attributedText = makeIconBeforeText(icon: "text.bubble")
        return label
    }()
    lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: ThemeFont.fontRegular, size: 14)
        label.attributedText = makeIconBeforeText(icon: "arrow.turn.down.right")
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
        bt.titleLabel?.font = UIFont(name: ThemeFont.fontMedium, size: 16)
        bt.titleLabel?.textAlignment = .center
        bt.backgroundColor = ThemeColor.mainOrange
        return bt
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeIconBeforeText(icon: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: icon)
        attachment.bounds = CGRect(x: 0, y: -2, width: 20, height: 20) // 이미지 크기 조정
        
        // 이미지와 텍스트 결합
        let iconString = NSAttributedString(attachment: attachment)
        //let textString = NSAttributedString(string: " 4.5", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(iconString)
        //mutableAttributedString.append(textString)
        
        return mutableAttributedString
    }
    
    func setConstraints() {
        [ratingLabel, reviewsLabel, distanceLabel].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [titleLabel, scrapButton, addressLabel, line, stackView, findFriendButton].forEach {
            self.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        scrapButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.verticalEdges.equalTo(titleLabel.snp.verticalEdges)
            make.width.equalTo(self.scrapButton.snp.height)
            make.leading.equalTo(titleLabel.snp.trailing).inset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().inset(10)
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom).offset(3)
            make.horizontalEdges.equalTo(line)
        }
        
        findFriendButton.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(5)
            make.horizontalEdges.bottom.equalToSuperview().inset(10)
        }
    }
}
