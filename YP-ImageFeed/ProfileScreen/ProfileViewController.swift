//
//  ProfileViewController.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.02.2023.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func tapExitButton(_ sender: UIButton)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    var presenter: ProfileViewPresenterProtocol?
    
    private var nameLabel: UILabel = UILabel()
    private var idLabel: UILabel = UILabel()
    private var statusLabel: UILabel = UILabel()
    private var exitButton: UIButton?
    private var userPhoto: UIImageView?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfileViewPresenter()
        presenter?.view = self
        
        createImages()
        createLabels()
        createButtons()
        view.backgroundColor = UIColor(named: "YPBlack")
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main) {
                [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func createImages() {
        guard let profilePic = presenter?.createImage else { return }
        
        view.addSubview(profilePic)
        
        NSLayoutConstraint.activate([
            profilePic.heightAnchor.constraint(equalToConstant: 70),
            profilePic.widthAnchor.constraint(equalToConstant: 70),
            
            profilePic.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profilePic.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        userPhoto = profilePic
    }
    
    private func createLabels() {
        guard let userPhoto = userPhoto else { return }
        
        guard let nameLabel = presenter?.createLabel(text: "Екатерина Новикова", color: .white, font: UIFont.systemFont(ofSize: 23, weight: .bold)) else { return }
        
        view.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: userPhoto.bottomAnchor, constant: 8).isActive = true
        
        self.nameLabel = nameLabel
        
        guard let idLabel = presenter?.createLabel(text: "@ekaterina_nov", color: UIColor(named: "YPGray")!, font: UIFont.systemFont(ofSize: 13, weight: .regular)) else { return }
        
        view.addSubview(idLabel)
        
        idLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        self.idLabel = idLabel
        
        guard let statusLabel = presenter?.createLabel(text: "Hello, world!", color: .white, font: UIFont.systemFont(ofSize: 13, weight: .regular)) else { return }
        
        view.addSubview(statusLabel)
        
        statusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        statusLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8).isActive = true
        
        self.statusLabel = statusLabel
    }
    
    private func createButtons() {
        guard let exitButton = presenter?.createButton else { return }
        
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24),
            
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40)
        ])
        
        exitButton.accessibilityIdentifier = "logout button"
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
    
    @objc func tapExitButton(_ sender: UIButton) {
        showAlert()
    }
    
}

extension ProfileViewController: AlertPresenterDelegate {
    func showAlert() {
        let alertDelegate = AlertPresenter(delegate: self)
        guard let model = presenter?.createAlertModel else { return }
        alertDelegate.showAlertWithTwoButton(model: model)
    }
}
