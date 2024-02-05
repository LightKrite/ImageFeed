//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 03.01.2024.
//

import Foundation
import UIKit


final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraits()
    }
    
    private func setupViews() {
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(profileDescriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraits() {
        NSLayoutConstraint.activate([imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                                     imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                                     imageView.widthAnchor.constraint(equalToConstant: 70),
                                     imageView.heightAnchor.constraint(equalToConstant: 70)])
        
        NSLayoutConstraint.activate([nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                                     nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8)])
        
        NSLayoutConstraint.activate([usernameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                                     usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)])
        
        NSLayoutConstraint.activate([profileDescriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                                     profileDescriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8)])
        
        NSLayoutConstraint.activate([logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                                     logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)])
    }
    
    private let imageView: UIImageView = {
        let profileImage = UIImage(named: "avatar")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        return profileImageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let profileDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var logoutButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "exitButton")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ypRed
        return button
    }()
    
    @objc
    private func didTapButton() {
        nameLabel.removeFromSuperview()
        usernameLabel.removeFromSuperview()
        profileDescriptionLabel.removeFromSuperview()
    }
}




