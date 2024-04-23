//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 03.01.2024.
//

import Foundation
import UIKit
import Kingfisher


final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let oAuthStorage = OAuth2Storage()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    private let profilePhoto: UIImageView = {
        let image = UIImage(named: "userPhoto")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaerina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "exitButton")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc func exitButtonTapped() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupAllConstraints()
        updateProfileDetails()
        
        view.backgroundColor = .ypBlack
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        
        let cache = ImageCache.default
        cache.clearDiskCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 42)
        
        profilePhoto.kf.setImage(with: url,
                                 placeholder: UIImage(named: "placeholder"),
                                 options: [.processor(processor), .transition(.fade(1))])
    }
    
    private func setupViews() {
        view.addSubview(profilePhoto)
        view.addSubview(nameLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupAllConstraints() {
        NSLayoutConstraint.activate([
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            profilePhoto.widthAnchor.constraint(equalToConstant: 70),
            profilePhoto.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profilePhoto.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            
            nameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor)
        ])
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    private let profileService = ProfileService.shared
//    private var avatarViewVar = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
//    private var nameLabelVar: UILabel?
//    private var loginLabelVar: UILabel?
//    private var profileImageServiceObserver: NSObjectProtocol?
//
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        profileImageServiceObserver = NotificationCenter.default
//            .addObserver(
//                forName: ProfileImageService.didChangeNotification,
//                object: nil,
//                queue: .main) {[weak self] _ in
//                guard let self = self else { return }
//                    self.updateAvatar()
//            }
//        updateAvatar()
//
//        view.backgroundColor = UIColor(named: "YP Black")
//        createViewAndLabel()
//
//    }
//
//    private func updateAvatar() {
//        guard
//            let profileImageURL = ProfileImageService.shared.avatarURL,
//            let url = URL(string: profileImageURL)
//        else { return }
//        avatarViewVar.kf.indicatorType = .activity
//        let processor = RoundCornerImageProcessor(cornerRadius: 40)
//        avatarViewVar.kf.setImage(
//            with: url,
//            placeholder: UIImage(named: "userpickStub"),
//            options: [.processor(processor)])
//    }
//
//    private func createViewAndLabel() {
//        guard let profile = profileService.profile else { return }
//        createAvatarView()
//        createNameLabel(profile.name)
//        createLoginLabel(profile.loginName)
//        createDescriptionLabel(profile.bio)
//    }
//
//    private func createAvatarView() {
//        let avatarView = avatarViewVar
//        avatarView.layer.cornerRadius = 35
//        avatarView.layer.masksToBounds = true
//        avatarView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(avatarView)
//        avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
//        avatarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
//        avatarView.heightAnchor.constraint(equalToConstant: 70).isActive = true
//        avatarView.widthAnchor.constraint(equalToConstant: 70).isActive = true
//
//    }
//
//    private func createNameLabel(_ name: String) {
//        let nameLabel = UILabel()
//        nameLabel.text = name
//        nameLabel.textColor = UIColor(named: "YP White")
//        nameLabel.font = .boldSystemFont(ofSize: 23)
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(nameLabel)
//        nameLabel.topAnchor.constraint(equalTo: self.avatarViewVar.bottomAnchor, constant: 8).isActive = true
//        nameLabel.leadingAnchor.constraint(equalTo: avatarViewVar.leadingAnchor).isActive = true
//        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
//        self.nameLabelVar = nameLabel
//    }
//
//    private func createLoginLabel(_ login: String) {
//        let loginLabel = UILabel()
//        loginLabel.text = login
//        loginLabel.textColor = UIColor(named: "YP Gray")
//        loginLabel.font = .systemFont(ofSize: 13)
//        loginLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loginLabel)
//        loginLabel.topAnchor.constraint(equalTo: nameLabelVar!.bottomAnchor, constant: 8).isActive = true
//        loginLabel.leadingAnchor.constraint(equalTo: nameLabelVar!.leadingAnchor).isActive = true
//        loginLabel.trailingAnchor.constraint(equalTo: nameLabelVar!.trailingAnchor).isActive = true
//        self.loginLabelVar = loginLabel
//    }
//
//    private func createDescriptionLabel(_ bio: String) {
//        let descriptionLabel = UILabel()
//        descriptionLabel.text = bio
//        descriptionLabel.textColor = UIColor(named: "YP White")
//        descriptionLabel.font = .systemFont(ofSize: 13)
//        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(descriptionLabel)
//        descriptionLabel.topAnchor.constraint(equalTo: loginLabelVar!.bottomAnchor, constant: 8).isActive = true
//        descriptionLabel.leadingAnchor.constraint(equalTo: nameLabelVar!.leadingAnchor).isActive = true
//        descriptionLabel.trailingAnchor.constraint(equalTo: nameLabelVar!.trailingAnchor).isActive = true
//    }
//
//    private func createLogoutButton() {
//        let logoutButton = UIButton()
//        logoutButton.setImage(UIImage(named: "exitButton"), for: .normal)
//        logoutButton.addTarget(self, action: #selector(Self.didTapButton), for: UIControl.Event.touchUpInside)
//        logoutButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(logoutButton)
//        logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 55).isActive = true
//        logoutButton.leadingAnchor.constraint(greaterThanOrEqualTo: avatarViewVar.trailingAnchor).isActive = true
//        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
//    }
//
//    @objc
//    private func didTapButton() {
//
//    }
}


extension ProfileViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

private extension ProfileViewController {
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        print("зашел в updateProfileDetails")
        nameLabel.text = "\(profile.firstName) \(profile.lastName ?? "")"
        nicknameLabel.text = "@\(profile.username)"
        descriptionLabel.text = profile.bio
    }
}
