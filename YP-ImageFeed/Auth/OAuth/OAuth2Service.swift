//
//  OAuth2Service.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.03.2023.
//

import Foundation

final class OAuth2Service{
    
    private static var task: URLSessionTask?
    
    private init() {}
    
    static func fetchOAuthToken( code: String,
                                 completion: @escaping(Result<OAuthTokenResponseBody, Error>) -> Void ) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createTokenRequest(code: code)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: {_ in} ,completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private static func createTokenRequest(code: String) -> URLRequest {
        //создание URL
        var urlComponents = URLComponents(string:  unsplashTokenURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}
