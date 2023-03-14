//
//  OAuthTokenResponse.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.03.2023.
//

/*
 Пример ответа
 {
 "access_token": "091343ce13c8ae780065ecb3b13dc903475dd22cb78a05503c2e0c69c5e98044",
 "token_type": "bearer",
 "scope": "public read_photos write_photos",
 "created_at": 1436544465
 }
 */

import Foundation

struct OAuthTokenResponseBody: Decodable {
    
    let token: String
    let type: String
    let scope: String
    let createdAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case type = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
