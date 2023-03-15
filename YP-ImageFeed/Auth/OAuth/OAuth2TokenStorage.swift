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
    private let key = "token"
    
    var token: String? {
        get {
            return keychain.string(forKey: key)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: key)
        }
    }
    
    func delete() {
        keychain.removeObject(forKey: key)
    }
}
