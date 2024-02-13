//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Egor Partenko on 11.02.2024.
//

import Foundation
import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
