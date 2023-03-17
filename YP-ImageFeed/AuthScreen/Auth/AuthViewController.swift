//
//  AuthViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 01.03.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private let webViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(webViewSegueIdentifier)") }
            
            let webViewPresenter = WebViewPresenter(authHelper: AuthHelper(configuration: AuthConfiguration.standard))
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(vc: self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController: AlertPresenterDelegate {
    func showAlert() {
        let alertDelegate = AlertPresenter(delegate: self)
        let model = AlertModel(title: "Что-то пошло не так(", message: "Не удалось войти в систему", firstButtonText: "Ок", firstButtonCompletion: nil, secondButtonText: nil, secondButtonCompletion: nil)
        alertDelegate.showAlertWithOneButton(model: model)
    }
}
