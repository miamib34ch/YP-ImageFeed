//
//  SplashViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 03.03.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = UIColor(named: "YPBlack")
        createImage()
        
        if let token = OAuth2TokenStorage().token {
            fetchProfile(vc: nil, token: token)
        } else {
            let auth = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController")
            guard let auth = auth as? AuthViewController else { return }
            auth.delegate = self
            auth.modalPresentationStyle = .fullScreen
            present(auth, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `Window` приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        
        // Cоздаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора.
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(vc: AuthViewController, code: String) {
        UIBlockingProgressHUD.show()
        OAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                OAuth2TokenStorage().token = response.token
                self.fetchProfile(vc: vc, token: response.token)
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                vc.dismiss(animated: true) // Убираем webView
                vc.showAler()
            }
        }
    }
    
    private func fetchProfile(vc: AuthViewController?, token: String) {
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let profileResult):
                self.switchToTabBarController()
                guard let username = profileResult.username else { return }
                self.fetchProfileImage(username: username)
            case .failure(_):
                vc?.dismiss(animated: true) // Убираем webView
                vc?.showAler()
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username, { _ in })
    }
    
    private func createImage() {
        let pic = UIImageView(image: UIImage(named: "Vector"))
        pic.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pic)
        
        pic.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            pic.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pic.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(vc: AuthViewController, didAuthenticateWithCode code: String) {
        fetchOAuthToken(vc: vc, code: code)
    }
}

