//
//  OAuth2Storage.swift
//  ImageFeed
//
//  Created by Egor Partenko on 16.02.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2Storage {
    private let key = "token"
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: key)
        }
        set {
            KeychainWrapper.standard.set(newValue!, forKey: key)
        }
    }
}
