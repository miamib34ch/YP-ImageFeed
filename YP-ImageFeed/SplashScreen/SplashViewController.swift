//
//  SplashViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 03.03.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController{
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegueIdentifier"
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if let token = OAuth2TokenStorage().token {
            fetchProfile(vc: nil, token: token)
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            
            // Найдём в иерархии AuthViewController
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)") }
            
            // Установим делегатом контроллера наш SplashViewController
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `Window` приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        
        // Cоздаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора.
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(vc: AuthViewController, code: String){
        UIBlockingProgressHUD.show()
        OAuth2Service.fetchOAuthToken(code:code){ [weak self] result in
            guard let self = self else {return}
            switch result{
            case .success(let response):
                OAuth2TokenStorage().token = response.token
                self.fetchProfile(vc: vc,token: response.token)
                break
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                vc.dismiss(animated: true) //убираем webView
                vc.showAler()
                break
            }
        }
    }
    
    private func fetchProfile(vc: AuthViewController?, token: String){
        ProfileService.shared.fetchProfile(token){[weak self] result in
            guard let self = self else {return}
            UIBlockingProgressHUD.dismiss()
            switch result{
            case .success:
                self.switchToTabBarController()
                self.fetchProfileImage(username: (ProfileService.shared.profile?.username)!)
            case .failure(_):
                vc?.dismiss(animated: true) //убираем webView
                vc?.showAler()
                break
            }
        }
    }
    
    private func fetchProfileImage(username: String){
        ProfileImageService.shared.fetchProfileImageURL(username: username, {_ in})
    }
}

extension SplashViewController: AuthViewControllerDelegate{
    func authViewController(vc: AuthViewController, didAuthenticateWithCode code: String) {
        fetchOAuthToken(vc: vc, code: code)
    }
}

