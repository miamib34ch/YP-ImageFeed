//
//  OAuth2Service.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.03.2023.
//

import Foundation

final class OAuth2Service{
    
    private static var lastCode: String?
    private static var task: URLSessionTask?
    
    enum NetworkError: Error {
        case customError(String)
        case errorResponse(Error)
    }
    
    private init() {}
    
    static func fetchOAuthToken( code: String,
                                 completion: @escaping(Result<String, Error>) -> Void ) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = createTokenRequest(code: code)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                // проверяем, пришла ли ошибка
                if let error = error {
                    completion(.failure(NetworkError.errorResponse(error)))
                    lastCode = nil
                    return
                }
                
                // проверяем, что нам пришёл успешный код ответа
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.customError("Не успешный код от сервера")))
                    lastCode = nil
                    return
                }
                
                // возвращаем данные
                guard let data = data else {
                    completion(.failure(NetworkError.customError("Нет данных")))
                    lastCode = nil
                    return
                }
                do{
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(response.token))
                    self.task = nil
                    return
                }
                catch{
                    completion(.failure(NetworkError.customError("Не удалось декодировать")))
                    lastCode = nil
                    return
                }
            }
        }
        
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
