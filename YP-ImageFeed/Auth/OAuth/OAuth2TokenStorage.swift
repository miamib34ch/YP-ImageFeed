//
//  OAuth2TokenStorage.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 03.03.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    private let keychain = KeychainWrapper.standard
    
    var token: String? {
        get {
            return keychain.string(forKey: "token")
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: "token")
        }
    }
}
