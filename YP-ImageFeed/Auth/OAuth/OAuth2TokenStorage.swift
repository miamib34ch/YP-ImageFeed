//
//  OAuth2TokenStorage.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 03.03.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage{
    
    var token: String? {
        get{
            return KeychainWrapper.standard.string(forKey: "token")
        }
        set{
            guard let newValue = newValue else {return}
            KeychainWrapper.standard.set(newValue, forKey: "token")
        }
    }
}
