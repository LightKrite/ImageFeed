//
//  Profile.swift
//  ImageFeed
//
//  Created by Egor Partenko on 08.04.2024.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}

struct Profile {
    let username: String?
    let name: String?
    let loginName: String?
    let bio: String?
    
    init(ProfileResult: ProfileResult) {
        self.username = ProfileResult.username
        self.name = ProfileResult.firstName + " " + (ProfileResult.lastName ?? "")
        self.loginName = "@" + (ProfileResult.username)
        self.bio = ProfileResult.bio
    }
}


