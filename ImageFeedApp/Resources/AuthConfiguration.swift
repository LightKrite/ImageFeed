//
//  Constants.swift
//  ImageFeed
//
//  Created by Egor Partenko on 07.02.2024.
//

import Foundation

enum APIConstatns {
    
    static let accessKey = "G83xOSdWPtaspXApUmBrQWRIleje_q1CcBJovb8GvOE"
    static let secretKey = "FCOLddHqXsFBwAd-IWCKzCL-UCFr8s5nao_a8kbyHek"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURL = URL(string: defaultBaseURLString)!
    static let defaultAPIBaseURLString = "https://api.unsplash.com"
    static let defaultAPIBaseURL = URL(string: defaultAPIBaseURLString)!
    
}

struct AuthConfiguration {
    let access_Key: String
    let secret_Key: String
    let redirect_URI: String
    let access_Scope: String
    let default_Base_URL: URL
    let authorize_URL_String: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: APIConstatns.accessKey,
                                 secretKey: APIConstatns.secretKey,
                                 redirectURI: APIConstatns.redirectURI,
                                 accessScope: APIConstatns.accessScope,
                                 authorizeURLString: APIConstatns.defaultBaseURLString,
                                 defaultBaseURL: APIConstatns.defaultAPIBaseURL)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authorizeURLString: String, defaultBaseURL: URL) {
        self.access_Key = accessKey
        self.secret_Key = secretKey
        self.redirect_URI = redirectURI
        self.access_Scope = accessScope
        self.default_Base_URL = defaultBaseURL
        self.authorize_URL_String = authorizeURLString
    }
}

