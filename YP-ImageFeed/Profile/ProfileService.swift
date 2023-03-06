//
//  ProfileService.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 05.03.2023.
//

import Foundation

final class ProfileService {
    
    public static var shared = ProfileService()
    
    private(set) var profile: Profile?
    
    private var task: URLSessionTask?
    
    private enum NetworkError: Error {
        case customError(String)
        case errorResponse(Error)
    }
    
    private init() {}
    
    func fetchProfile(_ token: String,
                             completion: @escaping (Result<Profile, Error>) -> Void) {
    
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createProfileRequest(token)
        
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
                    completion(.failure(NetworkError.customError("Не успешный код от сервера")))
                    return
                }
                
                // возвращаем данные
                guard let data = data else {
                    completion(.failure(NetworkError.customError("Нет данных")))
                    return
                }
                do{
                    let response = try JSONDecoder().decode(ProfileResult.self, from: data)
                    self.profile = Profile(profileResult: response)
                    completion(.success(self.profile!))
                    return
                }
                catch{
                    completion(.failure(NetworkError.customError("Не удалось декодировать")))
                    return
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func createProfileRequest(_ token: String) -> URLRequest {
        
        var request = URLRequest(url: URL(string: "/me", relativeTo: defaultBaseURL)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
