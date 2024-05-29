//
//  MyPageViewController.swift
//  TteoPpoKki4U
//
//  Created by Dongik Song on 5/28/24.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController {

    let myPageView = MyPageView()
    let myPageVM = MyPageVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Profile"
        
        view.addSubview(myPageView)
        
        myPageView.snp.makeConstraints { make in
                    make.top.equalTo(view.snp.top).offset(180)
                    make.leading.trailing.bottom.equalTo(view)
                }
        
        myPageView.collectionView.dataSource = self
        myPageView.collectionView.delegate = self
    }
}

extension MyPageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return myPageVM.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPageVM.sections[section].options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPageCollectionViewCell.identifier, for: indexPath) as! MyPageCollectionViewCell
        let option = myPageVM.sections[indexPath.section].options[indexPath.item]
        cell.configure(with: option)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        switch indexPath {
        case [0, 0]:
            let personalInfoVC = PersonalInfoViewController()
            present(personalInfoVC, animated: true)
        case [1, 0]:
            print(indexPath)
        case [1, 1]:
            print("2")
        case [1, 2]:
            print("3")
        case [2, 0]:
            print("4")
        default:
            return
        }
    }
}


