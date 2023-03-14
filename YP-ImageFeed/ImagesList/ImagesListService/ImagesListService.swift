//
//  ImagesListService.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 14.03.2023.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        if task != nil {
            return
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = createPhotosRequest("\(nextPage)")
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
        
    }
    
    private func completion(_ res: Result<[PhotoResult],Error>) {
        switch res {
        case .success(let photoResult):
            photoResult.forEach() { res in
                guard let thumb = res.urls?.thumb,
                      let large = res.urls?.full
                else { return }
                
                // MARK: Переписать эту часть: не нравится обработка даты, обработчик даты ещё есть в контроллере
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                let date = dateFormatter.date(from: (res.created_at ?? ""))
                
                let photo = Photo(id: res.id,
                                  size: CGSize(width: res.width, height: res.height),
                                  createdAt: date,
                                  welcomeDescription: res.description,
                                  thumbImageURL: thumb,
                                  largeImageURL: large,
                                  isLiked: res.liked_by_user)
                
                photos.append(photo)
            }
            
            if lastLoadedPage == nil{
                lastLoadedPage = 1
            } else{
                lastLoadedPage! += 1
            }
            task = nil
            
            NotificationCenter.default.post(name: ImagesListService.DidChangeNotification,
                                            object: self)
        case .failure(let error):
            print(error)
        }
    }
    
    private func createPhotosRequest(_ nextPage: String) -> URLRequest {
        // Создание URL
        var urlComponents = URLComponents(string: URL(string: "/photos", relativeTo: defaultBaseURL)!.absoluteString)!
        urlComponents.queryItems = [URLQueryItem(name: "page", value: nextPage)]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = OAuth2TokenStorage().token ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}

