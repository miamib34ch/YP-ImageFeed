//
//  Photo.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 14.03.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
