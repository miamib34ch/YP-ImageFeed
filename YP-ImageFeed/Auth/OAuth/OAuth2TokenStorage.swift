//
//  OAuth2TokenStorage.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 03.03.2023.
//

import Foundation

final class OAuth2TokenStorage{
    
    private let userDefaults = UserDefaults.standard // хранилище данных
    
    var token: String? {
        get{
            return userDefaults.string(forKey: "token")
        }
        set{
            userDefaults.set(newValue, forKey: "token")
        }
    }
}
