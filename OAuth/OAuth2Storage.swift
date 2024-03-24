//
//  OAuth2Storage.swift
//  ImageFeed
//
//  Created by Egor Partenko on 16.02.2024.
//

import Foundation

final class OAuth2Storage {
    private let key = "token"
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: APIConstatns.bearerToken)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: APIConstatns.bearerToken)
        }
    }
}
