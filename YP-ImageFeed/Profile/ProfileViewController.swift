//
//  ProfileViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.02.2023.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    private let nameLabel: UILabel = UILabel()
    private let idLabel: UILabel = UILabel()
    private let statusLabel: UILabel = UILabel()
    private var exitButton: UIButton?
    private var userPhoto: UIImageView?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createImages()
        createLabels()
        createButtons()
        view.backgroundColor = UIColor(named: "YPBlack")
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.DidChangeNotification,
                         object: nil,
                         queue: .main) {
                [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func createImages()
    {
        let profilePic = UIImageView(image: UIImage(named: "Placeholder"))
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profilePic)
        
        profilePic.contentMode = .scaleAspectFit
        
        //закругление
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            profilePic.heightAnchor.constraint(equalToConstant: 70),
            profilePic.widthAnchor.constraint(equalToConstant: 70),
            
            profilePic.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profilePic.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        userPhoto = profilePic
    }
    
    private func createLabels()
    {
        guard let userPhoto = userPhoto else {
            return
        }
        
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: userPhoto.bottomAnchor, constant: 8).isActive = true
        
        
        idLabel.text = "@ekaterina_nov"
        idLabel.textColor = UIColor(named: "YPGray")
        idLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(idLabel)
        
        idLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        
        statusLabel.text = "Hello, world!"
        statusLabel.textColor = .white
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statusLabel)
        
        statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        statusLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    private func createButtons() {
        guard let image = UIImage(named: "Exit") else { return }
        let exitButton = UIButton.systemButton(with: image, target: self, action: #selector(tapExitButton))
        exitButton.tintColor = UIColor(named: "YPRed")
        
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
    }
    
    private func updateProfileDetails(profile: Profile) {
        self.nameLabel.text = profile.name
        self.idLabel.text = profile.loginName
        self.statusLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL),
            let userPhoto = userPhoto
        else { return }
        
        userPhoto.kf.setImage(with: url,placeholder: UIImage(named: "Placeholder"))
    }
    
    @objc private func tapExitButton(_ sender: UIButton) {
        OAuth2TokenStorage().delete()
        ProfileViewController.clean()
        let splash = SplashViewController()
        // Получаем экземпляр `Window` приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = splash
    }
    
    static func clean() {
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
