//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 16.02.2024.
//

import Foundation
import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let showAuthScreenId = "ShowAuthenticationScreen"
    private let profileService = ProfileService()
    private let storage = OAuth2Storage()
    private var logoView: UIImageView?
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor(named: "YP Black")
        createLogoView()
        if OAuth2Storage().token != nil {
            fetchProfile(token: OAuth2Storage().token!)
        } else {
            presentAuth()
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
    
    private func createLogoView() {
        let logoView = UIImageView(image: UIImage(named: "splash_screen_logo"))
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func presentAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewControllerID")
        guard let authViewController = viewController as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    private func fetchOAuthToken(_ code: String) {
            OAuth2Service.shared.fetchAuthToken(code: code) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let token):
                    self.fetchProfile(token: token)
                    UIBlockingProgressHUD.show()
                case .failure(let error):
                    UIBlockingProgressHUD.show()
                    print("токен не получен \(error)")
                    self.showAlert(parameter: code, .tokenProblem)
                }
            }
        }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("профиль не получен \(error)")
                self.showAlert(parameter: token, .profileProblem)
            }
        }
    }
    
    private func showAlert(parameter: String, _ problem: WhatProblem) {
        let alert = UIAlertController(title: "Что то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            switch problem {
            case .tokenProblem: self.fetchOAuthToken(parameter)
            case .profileProblem: self.fetchProfile(token: parameter)
            }
        }
        alert.addAction(alertAction)
        let vc = self.presentedViewController ?? self
        vc.present(alert, animated: true)
    }
    
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    
    enum WhatProblem {
        case tokenProblem
        case profileProblem
    }
}
