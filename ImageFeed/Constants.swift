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


