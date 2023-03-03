//
//  OAuth2Service.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 02.03.2023.
//

import Foundation

class OAuth2Service{
    
    enum NetworkError: Error {
        case notSuccesResponse(String)
        case notSuccesDecode(String)
        case noData(String)
        case errorResponse(Error)
    }
    
    static func fetchOAuthToken( code: String,
                                 completion: @escaping(Result<String, Error>) -> Void ) {
        let request = createTokenRequest(code: code)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                // проверяем, пришла ли ошибка
                if let error = error {
                    completion(.failure(NetworkError.errorResponse(error)))
                    return
                }
                
                // проверяем, что нам пришёл успешный код ответа
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.notSuccesResponse("Не успешный код от сервера")))
                    return
                }
                
                // возвращаем данные
                guard let data = data else {
                    completion(.failure(NetworkError.noData("Нет данных")))
                    return
                }
                do{
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(response.token))
                    return
                }
                catch{
                    completion(.failure(NetworkError.notSuccesDecode("Не удалось декодировать")))
                    return
                }
            }
        }
        task.resume()
    }
    
    private static func createTokenRequest(code: String) -> URLRequest {
        //создание URL
        var urlComponents = URLComponents(string:  UnsplashTokenURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}
