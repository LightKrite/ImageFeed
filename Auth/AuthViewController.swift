//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 08.02.2024.
//

import Foundation
import UIKit

final class AuthViewController: UIViewController {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    
    
    private let logoView: UIImageView = {
        let logoImage = UIImage(named: "auth_screen_logo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc func buttonTapped() {
        print("Кнопка была нажата!")
        
        performSegue(withIdentifier: ShowWebViewSegueIdentifier, sender: self)
        
//        let webViewViewController = WebViewViewController()
//        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    private func setupViews() {
        view.addSubview(logoView)
        view.addSubview(loginButton)
    }
    
    private func setupConstraits() {
        NSLayoutConstraint.activate([logoView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                                     logoView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                                     logoView.widthAnchor.constraint(equalToConstant: 60),
                                     logoView.heightAnchor.constraint(equalToConstant: 60)])
        
        NSLayoutConstraint.activate([loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
                                     loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                                     loginButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16),
                                     loginButton.heightAnchor.constraint(equalToConstant: 48)])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraits()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        //TODO: in progress
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    
    
}


