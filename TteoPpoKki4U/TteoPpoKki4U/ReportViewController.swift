//
//  ReportViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/14/24.
//

import UIKit

class ReportViewController: UIViewController {
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "리뷰 신고하기"
        label.font = ThemeFont.fontBold()
        return label
    }()
    
    private let reasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "리뷰를 신고하는 이유를 알려주세요."
        label.font = ThemeFont.fontBold(size: 15)
        return label
    }()
    
    private let reasonSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "타당한 근거 없이 신고된 내용은 관리자 확인 후 반영되지 않을 수 있습니다."
        label.font = ThemeFont.fontELight(size: 12)
        label.textColor = .gray
        return label
    }()
    
    private let reasons: [String] = [
        "음란성, 욕설 등 부적절한 내용",
        "부적절한 홍보 또는 광고",
        "리뷰와 관련없는 사진 게시",
        "개인정보 유출 위험",
        "리뷰 작성 취지에 맞지 않는 내용(복사글 등)",
        "저작권 도용 의심(사진 등)",
        "기타(하단 내용 작성)"
    ]
    
    private var reasonButtons: [UIButton] = []
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        return textView
    }()
    
    private let reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        view.addSubview(reasonTitleLabel)
        view.addSubview(reasonSubtitleLabel)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(closeButton)
            make.centerX.equalTo(view)
        }
        
        reasonTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(32)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        reasonSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(reasonTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        var lastView: UIView = reasonSubtitleLabel
        
        for reason in reasons {
            let button = createCheckBoxButton(with: reason)
            reasonButtons.append(button)
            view.addSubview(button)
            
            button.snp.makeConstraints { make in
                make.top.equalTo(lastView.snp.bottom).offset(16)
                make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
                make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            }
            
            lastView = button
        }
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.equalTo(lastView.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(100)
        }
        
        view.addSubview(reportButton)
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }
    }
    
    private func createCheckBoxButton(with title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(checkBoxButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func reportButtonTapped() {
        
    }
    
    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
}
