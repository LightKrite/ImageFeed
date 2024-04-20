//
//  Profile.swift
//  ImageFeed
//
//  Created by Egor Partenko on 08.04.2024.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}



struct Profile {
    let username: String
    let firstName: String
    let lastName: String
    var name: String {
        return firstName + " " + lastName
    }
    var loginName: String {
        return "@" + username
    }
    var bio: String
}


