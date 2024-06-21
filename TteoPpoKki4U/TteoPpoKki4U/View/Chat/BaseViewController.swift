//
//  BaseViewController.swift
//  TteoPpoKki4U
//
//  Created by 최진문 on 2024/06/20.
//

import UIKit

class BaseViewController: UIViewController {
    
    weak var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
    }
    
    func showAlert(title: String? = nil,
                   message: String? = nil,
                   preferredStyle: UIAlertController.Style = .alert,
                   cancelButtonName: String? = nil,
                   confirmButtonName: String? = nil,
                   isExistsTextField: Bool = false,
                   cancelButtonCompletion: (() -> Void)? = nil,
                   confirmButtonCompletion: (() -> Void)? = nil) {
        let alertViewController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: preferredStyle)
        
        if let cancelButtonName = cancelButtonName {
            let cancelAction = UIAlertAction(title: cancelButtonName,
                                             style: .cancel) { _ in
                cancelButtonCompletion?()
            }
            alertViewController.addAction(cancelAction)
        }
        
        if let confirmButtonName = confirmButtonName {
            let confirmAction = UIAlertAction(title: confirmButtonName,
                                              style: .default) { _ in
                confirmButtonCompletion?()
            }
            alertViewController.addAction(confirmAction)
        }
        
        if isExistsTextField {
            alertViewController.addTextField { textField in
                textField.addTarget(self, action: #selector(self.didInputTextField(field:)), for: .editingChanged)
                textField.enablesReturnKeyAutomatically = true
                textField.autocapitalizationType = .words
                textField.clearButtonMode = .whileEditing
                textField.placeholder = "Channel name"
                textField.returnKeyType = .done
                textField.tintColor = ThemeColor.mainOrange
            }
        }
        
        alertController = alertViewController
        present(alertViewController, animated: true)
    }
    
    @objc private func didInputTextField(field: UITextField) {
        if let alertController = alertController {
            alertController.preferredAction?.isEnabled = field.hasText
        }
    }
}

