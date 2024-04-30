//
//  ImageListStructures.swift
//  ImageFeed
//
//  Created by Egor Partenko on 26.04.2024.
//

import Foundation

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let regularImageURL: String
    let smallImageURL: String
    let isLiked: Bool
    
    init(_ photoResult: PhotoResult, date: ISO8601DateFormatter) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = date.date(from: photoResult.createdAt ?? "")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.regularImageURL = photoResult.urls.regular
        self.smallImageURL = photoResult.urls.small
        self.isLiked = photoResult.likedByUser
    }
}

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}

struct UrlsResult: Decodable {
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoLike: Decodable {
    let photo: PhotoResult
}
