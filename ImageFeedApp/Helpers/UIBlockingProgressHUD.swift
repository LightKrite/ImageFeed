//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Egor Partenko on 05.04.2024.
//

import Foundation
import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static func showWithoutAnimation() {
        window?.isUserInteractionEnabled = false
    }
    static func dismissWithoutAnimation() {
        window?.isUserInteractionEnabled = true
    }
    
}
