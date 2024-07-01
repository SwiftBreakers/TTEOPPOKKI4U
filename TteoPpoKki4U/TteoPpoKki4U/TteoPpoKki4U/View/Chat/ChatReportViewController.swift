//
//  ChatReportViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatReportViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "채팅 신고하기"
        label.font = ThemeFont.fontBold(size: 24)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    private lazy var reasonTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "해당 채팅을 신고하는 이유를 알려주세요."
        label.font = ThemeFont.fontBold(size: 20)
        label.textColor = ThemeColor.mainBlack
        return label
    }()
    
    private lazy var reasonSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "타당한 근거 없이 신고된 내용은 관리자 확인 후\n반영되지 않을 수 있습니다."
        label.font = ThemeFont.fontELight(size: 17)
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    private lazy var reason1Label: UILabel = createReasonLabel(text: "관련 없는 사진 또는 글")
    private lazy var reason2Label: UILabel = createReasonLabel(text: "상업적 목적의 광고, 홍보글")
    private lazy var reason3Label: UILabel = createReasonLabel(text: "개인정보 유출 혹은 우려")
    private lazy var reason4Label: UILabel = createReasonLabel(text: "도용 혹은 저작권 침해 사진 또는 글")
    private lazy var reason5Label: UILabel = createReasonLabel(text: "무분별한 복사 혹은 도배글")
    private lazy var reason6Label: UILabel = createReasonLabel(text: "폭력성, 음란성 등 부적절한 내용")
    private lazy var reason7Label: UILabel = createReasonLabel(text: "기타(하단에 작성해주세요.)")
    
    private lazy var reason1CheckBox: UIButton = createCheckBoxButton()
    private lazy var reason2CheckBox: UIButton = createCheckBoxButton()
    private lazy var reason3CheckBox: UIButton = createCheckBoxButton()
    private lazy var reason4CheckBox: UIButton = createCheckBoxButton()
    private lazy var reason5CheckBox: UIButton = createCheckBoxButton()
    private lazy var reason6CheckBox: UIButton = createCheckBoxButton()
    private lazy var reason7CheckBox: UIButton = createCheckBoxButton()
    
    private var isRelated = false
    private var isCommercial = false
    private var isPrivacy = false
    private var isIllegal = false
    private var isSpam = false
    private var isSexual = false
    private var isEtc = false
    
    private lazy var textView = CustomTextView(target: self, action: #selector(doneButtonTapped))
    
    private lazy var reportButton: UIButton = {
        let button = UIButton()
        button.setTitle("신고하기", for: .normal)
        button.titleLabel?.font = ThemeFont.fontBold()
        button.titleLabel?.tintColor = .white
        button.backgroundColor = ThemeColor.mainOrange
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var userData: ReportUserData
    
    init(userData: ReportUserData) {
        self.userData = userData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let viewModel = ChatReportViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        print(userData)
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
            make.top.equalTo(reasonTitleLabel.snp.bottom).offset(25)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        setupReasonRow(label: reason1Label, checkBox: reason1CheckBox, topView: reasonSubtitleLabel)
        setupReasonRow(label: reason2Label, checkBox: reason2CheckBox, topView: reason1Label)
        setupReasonRow(label: reason3Label, checkBox: reason3CheckBox, topView: reason2Label)
        setupReasonRow(label: reason4Label, checkBox: reason4CheckBox, topView: reason3Label)
        setupReasonRow(label: reason5Label, checkBox: reason5CheckBox, topView: reason4Label)
        setupReasonRow(label: reason6Label, checkBox: reason6CheckBox, topView: reason5Label)
        setupReasonRow(label: reason7Label, checkBox: reason7CheckBox, topView: reason6Label)
        
        view.addSubview(textView)
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(reason7Label.snp.bottom).offset(32)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(200)
        }
        
        view.addSubview(reportButton)
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(50)
        }
    }
    
    private func setupReasonRow(label: UILabel, checkBox: UIButton, topView: UIView) {
        view.addSubview(label)
        view.addSubview(checkBox)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        checkBox.snp.makeConstraints { make in
            make.centerY.equalTo(label)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.width.height.equalTo(24)
        }
    }
    
    private func createReasonLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = ThemeFont.fontMedium(size: 18)
        label.textColor = ThemeColor.mainBlack
        return label
    }
    
    private func createCheckBoxButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.addTarget(self, action: #selector(checkBoxButtonTapped(_:)), for: .touchUpInside)
        button.tintColor = .black
        return button
    }
    
    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        switch sender {
        case reason1CheckBox:
            isRelated.toggle()
        case reason2CheckBox:
            isCommercial.toggle()
        case reason3CheckBox:
            isPrivacy.toggle()
        case reason4CheckBox:
            isIllegal.toggle()
        case reason5CheckBox:
            isSpam.toggle()
        case reason6CheckBox:
            isSexual.toggle()
        case reason7CheckBox:
            isEtc.toggle()
        default:
            break
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func reportButtonTapped() {
        guard let uid = Auth.auth().currentUser?.uid else {
            showMessage(title: "오류", message: "사용자 인증에 실패했습니다.")
            return
        }
        
        if !isRelated && !isCommercial && !isPrivacy && !isIllegal && !isSpam && !isSexual && !isEtc {
            showMessage(title: "오류", message: "하나 이상의 신고 사유를 선택해 주세요.")
            return
        }
        
        if isEtc == true && textView.text?.isEmpty ?? true {
            showMessage(title: "오류", message: "신고 사유를 입력해 주세요.")
            return
        }
        
        if isEtc == false && !textView.text.isEmpty {
            showMessage(title: "오류", message: "기타 사유를 선택한 경우에만 내용을 신고할 수 있습니다.")
            return
        }
        
        if uid == userData.senderId {
            showMessage(title: "오류", message: "본인의 채팅은 신고할 수 없습니다.")
        } else {
            Task {
                let reportData: [String: Any] = [
                    "isRelated": isRelated,
                    "isCommercial": isCommercial,
                    "isPrivacy": isPrivacy,
                    "isIllegal": isIllegal,
                    "isSpam": isSpam,
                    "isSexual": isSexual,
                    "isEtc": isEtc,
                    "content": textView.text ?? "",
                    "uid": uid,
                    "senderId": userData.senderId,
                    "messageContent": userData.content,
                    "channel": userData.channel,
                    "reportCount": userData.reportCount,
                    "sentDate": userData.sentDate
                ]
                await viewModel.addReportAndIncreaseCount(content: userData.content, channel: userData.channel, senderId: userData.senderId, reportData: reportData)
                if userData.url != "" {
                    await viewModel.fetchFilteredImages(forChannelName: userData.channel, senderId: userData.senderId, url: userData.url, isSexual: isSexual)
                } else {
                    await viewModel.fetchFilteredMessages(forChannelName: userData.channel, senderId: userData.senderId, content: userData.content, isSexual: isSexual)
                }
                showMessage(title: "신고가 완료되었습니다", message: "신고 내용은 관리자 검토 후 반영됩니다.") { [weak self] in
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    @objc private func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
}
