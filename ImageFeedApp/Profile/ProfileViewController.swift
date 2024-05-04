//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 03.01.2024.
//

import Foundation
import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func setupProfileDetails(name: String, login: String, bio: String)
    func setupAvatar(url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    private let profileService = ProfileService.shared
    private let oAuthStorage = OAuth2Storage()
    private let avatarPlaceholder = UIImage(named: "ImagePlaceholder")
    
    
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
        label.accessibilityIdentifier = "nameLabel"
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaerina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "nicknameLabel"
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
    
    var presenter: ProfileViewPresenterProtocol? = {
        return ProfileViewPresenter()
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "exitButton")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logout"
        
        button.addTarget(self, action: #selector(exitButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupViews()
        setupAllConstraints()
        
        presenter?.view = self
        presenter?.updateProfileDetails()
        presenter?.observerProfileImageService()
    }
    
    func setupProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        nicknameLabel.text = login
        descriptionLabel.text = bio
    }
    
    func setupAvatar(url: URL) {
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 42)
        
        profilePhoto.kf.setImage(with: url,
                                 placeholder: avatarPlaceholder,
                                 options: [.processor(processor),
                                           .transition(.fade(1))]) { [ weak self ] result in
                                               guard let self else { return }
                                               switch result {
                                               case .success(let image):
                                                   self.profilePhoto.image = image.image
                                               case .failure(let error):
                                                   debugPrint("failed to upload avatar \(error)")
                                               }
                                           }
    }
    
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        
        let cache = ImageCache.default
        cache.clearDiskCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 42)
        
        profilePhoto.kf.setImage(with: url,
                                 placeholder: avatarPlaceholder,
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
    
    @objc
           private func exitButtonTapped() {
               let alert = UIAlertController(title: "До встречи!", message: "Точно хотите выйти?", preferredStyle: .alert)
               
               let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
                   self.logoutClean()
               }
               
               let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
                   alert.dismiss(animated: true)
               }
               alert.addAction(yesAction)
               alert.addAction(noAction)
               present(alert, animated: true)
           }
    
}

private extension ProfileViewController {
    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }
        debugPrint("зашел в updateProfileDetails")
        nameLabel.text = "\(profile.firstName) \(profile.lastName ?? "")"
        nicknameLabel.text = "@\(profile.username)"
        descriptionLabel.text = profile.bio
    }
}

extension ProfileViewController {
    func logoutClean() {
        OAuth2Storage.shared.clean()
        WebViewViewController.clean()
        ImagesListViewController.clean()
        
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

extension ProfileViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
