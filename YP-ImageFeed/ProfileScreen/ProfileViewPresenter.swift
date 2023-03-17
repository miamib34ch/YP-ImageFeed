//
//  ProfileViewPresenter.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 16.03.2023.
//

import Foundation
import WebKit

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var createAlertModel: AlertModel { get }
    var createImage: UIImageView { get }
    var createButton: UIButton { get }
    
    func createLabel(text: String, color: UIColor, font: UIFont) -> UILabel
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var createImage: UIImageView {
        let profilePic = UIImageView(image: UIImage(named: "Placeholder"))
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        
        profilePic.contentMode = .scaleAspectFit
        
        //закругление
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.layer.masksToBounds = true
        
        return profilePic
    }
    
    var createButton: UIButton {
        guard let image = UIImage(named: "Exit"),
              let view = view as? ProfileViewController
        else { return UIButton() }
        let exitButton = UIButton.systemButton(with: image, target: view, action: #selector(view.tapExitButton(_:)))
        exitButton.tintColor = UIColor(named: "YPRed")
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }
    
    
    var createAlertModel: AlertModel {
        return AlertModel(title: "Пока, пока!", message: "Уверены, что хотите выйти?", firstButtonText: "Да", firstButtonCompletion: { [weak self] in
            guard let self = self else { return }
            OAuth2TokenStorage().delete()
            self.clean()
            let splash = SplashViewController()
            // Получаем экземпляр `Window` приложения
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
            window.rootViewController = splash
        }, secondButtonText: "Нет", secondButtonCompletion: nil)
    }
    
    func createLabel(text: String, color: UIColor, font: UIFont) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.text = text
        nameLabel.textColor = color
        nameLabel.font = font
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return nameLabel
    }
    
    private func clean() {
        // Очищаем все куки из хранилища.
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища.
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища.
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
