//
//  URLSessionExtension.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 09.03.2023.
//

import Foundation

extension URLSession {
    
    private enum NetworkError: Error {
        case customError(String)
        case errorResponse(Error)
    }
    
    final func objectTask<T: Decodable>(for request: URLRequest,
                                  saveDataFunc: @escaping (T) -> Void,
                                  completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
                                        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                
                // проверяем, пришла ли ошибка
                if let error = error {
                    completion(.failure(NetworkError.errorResponse(error)))
                    return
                }
                
                // проверяем, что нам пришёл успешный код ответа
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.customError("Не успешный код от сервера")))
                    return
                }
                
                // возвращаем данные
                guard let data = data else {
                    completion(.failure(NetworkError.customError("Нет данных")))
                    return
                }
                do{
                    let response = try JSONDecoder().decode(T.self, from: data)
                    saveDataFunc(response)
                    completion(.success(response))
                    return
                }
                catch{
                    completion(.failure(NetworkError.customError("Не удалось декодировать")))
                    return
                }
            }
        })
        return task
    }
}
