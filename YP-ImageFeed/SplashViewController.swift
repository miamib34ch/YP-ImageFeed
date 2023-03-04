//
//  SplashViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 03.03.2023.
//

import UIKit
import ProgressHUD

class SplashViewController: UIViewController{
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegueIdentifier"
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if OAuth2TokenStorage().token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
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
}

extension SplashViewController {
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
}

extension SplashViewController: AuthViewControllerDelegate{
    func authViewController(vc: AuthViewController, didAuthenticateWithCode code: String) {
        ProgressHUD.show()
        OAuth2Service.fetchOAuthToken(code:code){ [weak self] result in
            guard let self = self else {return}
            ProgressHUD.dismiss()
            switch result{
            case .success(let token):
                OAuth2TokenStorage().token = token
                self.switchToTabBarController()
            case .failure(let error):
                vc.dismiss(animated: true)
                //TODO: добавить алерт об ошибке
            }
        }
    }
}
