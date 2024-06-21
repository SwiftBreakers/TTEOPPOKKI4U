//
//  FullscreenViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/19.
//

import UIKit
import Kingfisher

class FullscreenViewController: UIViewController, UIScrollViewDelegate {
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    var imageURL: URL?
    var index: Int = 0 // 인덱스 추가

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupImageView()
        loadImage()
        addGestureRecognizers()
    }

    func setupScrollView() {
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        self.view.addSubview(scrollView)
    }
    
    func setupImageView() {
        imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
    }

    func loadImage() {
        if let imageURL = imageURL {
            imageView.kf.setImage(with: imageURL, placeholder: UIImage(named: "placeholder"))
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
    }

    func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
    }

    @objc func dismissFullscreenImage() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // UIScrollViewDelegate 메소드
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            if scale > scrollView.minimumZoomScale {
                UIView.animate(withDuration: 0.3) {
                    scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
                }
            }
        }
}
