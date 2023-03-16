//
//  Constants.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 28.02.2023.
//

import Foundation

let unsplashAccessKey = "EjFpIzIrfz5hdjlgr-YODPV_vha-CizW0cbv6J6iXiA"
let unsplashSecretKey = "AUBTkoTMCXSNpBUVfjPxJCk-pkGb-tL0BsQAE8-groc"
let unsplashRedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let unsplashAccessScope = "public+read_user+write_likes"

let unsplashDefaultBaseURL = URL(string: "https://api.unsplash.com")!
let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let unsplashTokenURLString = "https://unsplash.com/oauth/token"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authorizeURLString: String
    let tokenURLString: String
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: unsplashAccessKey,
                                 secretKey: unsplashSecretKey,
                                 redirectURI: unsplashRedirectURI,
                                 accessScope: unsplashAccessScope,
                                 defaultBaseURL: unsplashDefaultBaseURL,
                                 authorizeURLString: unsplashAuthorizeURLString,
                                 tokenURLString: unsplashTokenURLString)
    }
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authorizeURLString: String, tokenURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authorizeURLString = authorizeURLString
        self.tokenURLString = tokenURLString
    }
}
