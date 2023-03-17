//
//  ProfileService.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 05.03.2023.
//

import Foundation

final class ProfileService {
    
    static var shared = ProfileService()

    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfile(_ token: String,
                      completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createProfileRequest(token)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: saveFunc ,completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private func saveFunc(_ profileResult: ProfileResult) {
        profile = Profile(profileResult: profileResult)
    }
    
    private func createProfileRequest(_ token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "/me", relativeTo: AuthConfiguration.standard.defaultBaseURL)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
