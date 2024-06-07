//
//  ChatCollectionViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 6/7/24.
//

import UIKit


class ChatCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    private let reuseIdentifier = "ChatCollectionViewCell"
    
    
    private lazy var customInputView: CustomInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let iv = CustomInputView(frame: frame)
        //iv.delegate = self
        return iv
    }()
    
    
    // MARK: - Lifecycle
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchMessages()
    }
    
    override var inputAccessoryView: UIView? {
        get { return customInputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Helpers
    private func configureUI() {
        
        
        collectionView.backgroundColor = .white
        
        collectionView.register(ChatCollectionViewCell.self
                                , forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    private func fetchMessages() {
        
    }
}

extension ChatCollectionViewController {
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCollectionViewCell
        
        
        
        return cell
    }
    
    
}

extension ChatCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return .init(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = ChatCollectionViewCell(frame: frame)
        
        
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimeSize = cell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimeSize.height)
    }
}
