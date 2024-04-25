//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Egor Partenko on 09.02.2024.
//

import Foundation
import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet private var webView: WKWebView!
    @IBOutlet var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
        
        webView.navigationDelegate = self
        loadAuthView()
        updateProgress()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
            delegate?.webViewViewControllerDidCancel(self)
        }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

private extension WebViewViewController {
    func loadAuthView() {
        guard var components = URLComponents(string: APIConstatns.defaultBaseURLString) else {
            debugPrint("Не удалось обратиться к константе BaseURL")
            return
        }
        
        components.queryItems = [URLQueryItem(name: "client_id", value: APIConstatns.accessKey),
                                 URLQueryItem(name: "redirect_uri", value: APIConstatns.redirectURI),
                                 URLQueryItem(name: "response_type", value: "code"),
                                 URLQueryItem(name: "scope", value: APIConstatns.accessScope)]
        
        guard let url = components.url else {
            print("Не удалось собрать URL")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func fetchCode(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let code = fetchCode(from: navigationAction) {
                delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
}

extension WebViewViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
