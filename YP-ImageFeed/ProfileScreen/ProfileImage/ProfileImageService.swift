//
//  ProfileImageService.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 08.03.2023.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<UserResult, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createProfileImageRequest(username)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: saveFunc ,completion: completion)
        
        self.task = task
        task.resume()
        
    }
    
    private func saveFunc(_ userResult: UserResult) {
        avatarURL = userResult.profile_image.large
    }
    
    private func createProfileImageRequest(_ username: String) -> URLRequest {
        let token = OAuth2TokenStorage().token ?? ""
        var request = URLRequest(url: URL(string: "/users/\(username)", relativeTo: AuthConfiguration.standard.defaultBaseURL)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
