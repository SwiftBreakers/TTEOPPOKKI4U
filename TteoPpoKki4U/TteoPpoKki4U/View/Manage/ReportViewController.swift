//
//  ReportViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/14/24.
//

import UIKit
import FirebaseAuth

class ReportViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "리뷰 신고하기"
        label.font = ThemeFont.fontBold()
        label.textColor = .black
        return label
    }()
    
    private lazy var reasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "리뷰를 신고하는 이유를 알려주세요."
        label.font = ThemeFont.fontBold(size: 15)
        label.textColor = .black
        return label
    }()
    
    private lazy var reasonSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "타당한 근거 없이 신고된 내용은 관리자 확인 후 반영되지 않을 수 있습니다."
        label.font = ThemeFont.fontELight(size: 12)
        label.textColor = .gray
        return label
    }()
    
    private lazy var reasons: [String] = [
        "리뷰와 관련 없는 사진 또는 글",
        "상업적 목적의 광고, 홍보글",
        "개인정보 유출 혹은 우려",
        "도용 혹은 저작권 침해 사진 또는 글",
        "무분별한 복사 혹은 도배글",
        "폭력성, 음란성 등 부적절한 내용",
        "기타(하단에 작성해주세요.)"
    ]
    
    private var reasonButtons: [UIButton] = []
    
    private lazy var textView = CustomTextView(target: self, action: #selector(doneButtonTapped))
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var userData: ReviewModel?
    
    let viewModel = ReportViewModel()
    
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
        
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        
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
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if uid == userData!.uid {
            showMessage(title: "오류", message: "본인의 게시글은 신고 할 수 없습니다.")
        } else {
            viewModel.addReportCount(uid: userData!.uid, storeAddress: userData!.storeAddress, title: userData!.title) { [weak self] in
                self?.showMessage(title: "신고가 완료 되었습니다", message: "신고 내용은 관리자 검토후 반영 됩니다.", completion: {
                    self?.dismiss(animated: true)
                })
                
            }
        }
    }
    
    @objc private func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
}
