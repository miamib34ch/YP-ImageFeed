//
//  PhotoResult.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 14.03.2023.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let created_at: String?
    let description: String?
    let urls: UrlsResult?
    let liked_by_user: Bool
}

struct UrlsResult: Decodable {
    let full: String?
    let thumb: String?
}
