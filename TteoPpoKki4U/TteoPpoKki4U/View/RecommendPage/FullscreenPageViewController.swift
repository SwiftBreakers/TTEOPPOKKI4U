//
//  FullscreenPageViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/19.
//

import UIKit

class FullscreenPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var imageURLs: [URL] = []
    var currentIndex: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let startingViewController = viewControllerAtIndex(index: currentIndex) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func viewControllerAtIndex(index: Int) -> FullscreenViewController? {
        if index >= 0 && index < imageURLs.count {
            let fullscreenVC = FullscreenViewController()
            fullscreenVC.imageURL = imageURLs[index]
            fullscreenVC.index = index
            return fullscreenVC
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return imageURLs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    // UIPageViewControllerDataSource methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! FullscreenViewController).index
        if index == 0 {
            return nil
        }
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! FullscreenViewController).index
        index += 1
        if index == imageURLs.count {
            return nil
        }
        return viewControllerAtIndex(index: index)
    }}
