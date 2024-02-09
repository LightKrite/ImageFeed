//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 09.02.2024.
//

import Foundation
import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet var backButton: UIButton!
    
    @IBAction func didTapBackButton(_ sender: Any) {
        
    }
    
    
    override func viewDidLoad() {
        var urlComponents = URLComponents(string: defaultBaseURLString)!
        urlComponents.queryItems = [
        URLQueryItem(name: "client_id", value: AccessKey),
        URLQueryItem(name: "redirect_uri", value: RedirectURI),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope", value: AccessScope)
        ]
    }
}
