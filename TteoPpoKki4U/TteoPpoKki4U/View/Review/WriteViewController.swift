//
//  WriteViewController.swift
//  TteoPpoKki4U
//
//  Created by 박미림 on 6/3/24.
//

import UIKit
import SnapKit
import YPImagePicker
import Firebase
import FirebaseAuth
import FirebaseStorage
import Combine
import Kingfisher
import ProgressHUD

class WriteViewController: UIViewController {
    
    
    let starStackView = UIStackView()
    
    var starButtons: [UIButton] = []
    var selectedRating = 0
    
    let titleTextField = CustomTextField(placeholder: "제목",target: self, action: #selector(doneButtonTapped))
    let contentTextView = CustomTextView(target: self, action: #selector(doneButtonTapped))
    let addImageButton = UIButton()
    let cancelButton = UIButton()
    let submitButton = UIButton()
    let starLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeFont.fontMedium(size: 24)
        label.textColor = .black
        return label
    }()
    
    var selectedImages: [UIImage] = []
    let imageScrollView = UIScrollView()
    let imageStackView = UIStackView()
    
    var addressText: String?
    var storeTitleText: String?
    var reportCount: Int?
    
    var isEditMode: Bool = false
    var isNavagtion: Bool = false
    var review: ReviewModel?
    
    private var cancellables = Set<AnyCancellable>()
    let viewModel = ReviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bind()
        setDataForEdit()
    }
    
    private func setDataForEdit() {
        if review != nil {
            titleTextField.text = review?.title
            contentTextView.text = review?.content
            selectedRating = Int(review!.rating)
            addressText = review?.storeAddress
            storeTitleText = review?.storeName
            updateStarButtons()
            getImages()
        }
    }
    
    private func getImages() {
        review?.imageURL.forEach { url in
            guard let imageURL = URL(string: url) else { return }
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.addImageToStackView(image: image.image)
                        self.selectedImages.append(image.image)
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func bind() {
        viewModel.reviewPublisher.sink { [weak self] completion in
            switch completion {
            case .finished:
                return
            case .failure(let error) :
                self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)이 발생 했습니다.")
            }
        } receiveValue: { _ in
            
        }.store(in: &cancellables)
        
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        // 별점 라벨
        if isEditMode {
            starLabel.text = "별점 리뷰 수정"
            submitButton.setTitle("리뷰 수정", for: .normal)
        } else {
            starLabel.text = "별점 리뷰 작성"
            submitButton.setTitle("리뷰 등록", for: .normal)
        }
        
        view.addSubview(starLabel)
        starLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            make.centerX.equalToSuperview()
        }
        
        // 별점 버튼들 설정
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 10
        view.addSubview(starStackView)
        starStackView.snp.makeConstraints { make in
            make.top.equalTo(starLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(110)
            make.right.equalToSuperview().offset(-110)
        }
        
        for i in 1...5 {
            let button = UIButton()
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.tintColor = ThemeColor.mainOrange
            button.tag = i
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(button)
            starButtons.append(button)
        }
        
        // 제목 텍스트 필드 설정
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(starStackView.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        // 내용 텍스트 뷰 설정
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.cornerRadius = 5
        contentTextView.font = UIFont.systemFont(ofSize: 17)
        contentTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.addSubview(contentTextView)
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(180)
        }
        
        // 이미지 추가 버튼
        addImageButton.setImage(UIImage(systemName: "camera"), for: .normal)
        addImageButton.backgroundColor = .lightGray
        addImageButton.layer.cornerRadius = 5
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        view.addSubview(addImageButton)
        addImageButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(60)
        }
        // MARK: - 여기 스크롤 되는지 모르겠음....
        // 이미지 스크롤뷰 설정
        imageScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(imageScrollView)
        imageScrollView.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(90)
        }
        
        // 이미지 스택뷰 설정
        imageStackView.axis = .horizontal
        imageStackView.spacing = 10
        imageScrollView.addSubview(imageStackView)
        imageStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        
        // 취소 버튼 설정
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = ThemeFont.fontBold()
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .gray
        cancelButton.layer.cornerRadius = 5
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        // 등록 버튼 설정
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = ThemeFont.fontBold()
        submitButton.backgroundColor = ThemeColor.mainOrange
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalTo(cancelButton.snp.trailing).offset(16)
            make.height.equalTo(50)
        }
    }
    
    private func reviewTapped() {
        guard
            let uid = Auth.auth().currentUser?.uid,
            let title = titleTextField.text,
            let content = contentTextView.text
        else {
            return
        }
        ProgressHUD.animate()
        uploadImages(images: selectedImages)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.showMessage(title: "에러 발생", message: "\(error.localizedDescription)이 발생 했습니다.")
                }
            }, receiveValue: { [weak self] imageURLs in
                guard let self = self else { return }
                
                let dictionary: [String: Any] = [
                    db_uid: uid,
                    db_title: title,
                    db_storeAddress: self.addressText!,
                    db_storeName: self.storeTitleText!,
                    db_content: content,
                    db_rating: self.selectedRating,
                    db_imageURL: imageURLs,
                    db_isActive: true,
                    db_createdAt: self.isEditMode ? self.review!.createdAt : Timestamp(date: Date()),
                    db_updatedAt: Timestamp(date: Date()),
                    db_reportCount: review?.reportCount ?? 0
                ]
                
                
                if isEditMode {
                    viewModel.editUserReview(uid: uid, storeAddress: self.addressText!, title: review!.title, userDict: dictionary) {
                        ProgressHUD.remove()
                        self.showMessage(title: "리뷰 수정", message: "리뷰가 수정 되었습니다.") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    viewModel.createReview(userDict: dictionary) {
                        ProgressHUD.remove()
                        self.showMessage(title: "리뷰 등록", message: "리뷰가 등록 되었습니다") {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    private func updateStarButtons() {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < selectedRating
        }
    }
    
    @objc func starButtonTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarButtons()
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func submitButtonTapped() {
        if titleTextField.text?.isEmpty ?? true {
            showMessage(title: "제목이 없습니다", message: "제목을 입력해주세요.")
        } else if contentTextView.text?.isEmpty ?? true {
            showMessage(title: "내용이 없습니다", message: "내용을 입력해주세요.")
        } else if selectedRating == 0 {
           showMessage(title: "별점이 없습니다", message: "별점을 추가해주세요")
        } else {
            reviewTapped()
        }
    }
    
    @objc func addImageButtonTapped() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.maxNumberOfItems = 5
        config.startOnScreen = .library
        config.screens = [.library]
        config.showsPhotoFilters = false
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            for item in items {
                switch item {
                case .photo(let photo):
                    self.selectedImages.append(photo.image)
                    self.addImageToStackView(image: photo.image)
                case .video(_):
                    break
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    func addImageToStackView(image: UIImage) {
        let containerView = UIView()
        containerView.snp.makeConstraints { make in
            make.width.height.equalTo(90)
        }
        
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let removeButton = UIButton(type: .custom)
        removeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        removeButton.tintColor = .lightGray
        removeButton.addTarget(self, action: #selector(removeImageButtonTapped(_:)), for: .touchUpInside)
        containerView.addSubview(removeButton)
        removeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(5)
            make.width.height.equalTo(20)
        }
        
        imageStackView.addArrangedSubview(containerView)
    }
    
    @objc func removeImageButtonTapped(_ sender: UIButton) {
        guard let containerView = sender.superview else { return }
        
        if let index = imageStackView.arrangedSubviews.firstIndex(of: containerView) {
            selectedImages.remove(at: index)
        }
        
        containerView.removeFromSuperview()
    }
    
    @objc func doneButtonTapped() {
        view.endEditing(true)
    }
    
    func uploadImage(image: UIImage, index: Int) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let storageRef = Storage.storage().reference()
            guard let imageData = image.jpegData(compressionQuality: 0.3) else {
                return
            }
            
            let imageRef = storageRef.child("images/\(uid)\(index).jpg")
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let downloadURL = url {
                        promise(.success(downloadURL.absoluteString))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadImages(images: [UIImage]) -> AnyPublisher<[String], Error> {
        let publishers = images.enumerated().map { (index, image) in
            uploadImage(image: image, index: index + 1) // 인덱스를 1부터 시작
        }
        return Publishers.MergeMany(publishers)
            .collect()
            .eraseToAnyPublisher()
    }
}
