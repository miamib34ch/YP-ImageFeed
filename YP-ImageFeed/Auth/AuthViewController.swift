//
//  AuthViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 01.03.2023.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private let webViewSegueIdentifier = "ShowWebView"
    private weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == webViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(webViewSegueIdentifier)") }
            
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
    public func showError() {
        let alertDelegate = AlertPresenter(delegate: self)
        let model = AlertModel(title: "Что-то пошло не так(", message: "Не удалось войти в систему", buttonOneText: "Ок", completionOne: {}, buttonTwoText: "", completionTwo: {})
        alertDelegate.showOneButton(model: model)
    }
}
