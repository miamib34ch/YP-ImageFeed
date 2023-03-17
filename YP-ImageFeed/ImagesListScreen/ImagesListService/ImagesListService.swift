//
//  ImagesListService.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 14.03.2023.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private let dateFormatter = ISO8601DateFormatter()
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    
    private init() {}
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        
        if task != nil {
            return
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        let request = createPhotosRequest("\(nextPage)")
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: resultHandler)
        
        self.task = task
        task.resume()
        
    }
    
    private func resultHandler(_ res: Result<[PhotoResult],Error>) {
        switch res {
        case .success(let photoResult):
            photoResult.forEach() { res in
                guard let thumb = res.urls?.thumb,
                      let large = res.urls?.full
                else { return }
                
                // Заметил, что unspash присылает на каждой новой странице двумя первыми фотографиями - две фотографии с предудыщей страницы
                if (res.id == photoResult[0].id || res.id == photoResult[1].id) && (lastLoadedPage != nil) {
                    return
                }
                
                let date = dateFormatter.date(from: res.created_at ?? "")
                
                let photo = Photo(id: res.id,
                                  size: CGSize(width: res.width, height: res.height),
                                  createdAt: date,
                                  welcomeDescription: res.description,
                                  thumbImageURL: thumb,
                                  largeImageURL: large,
                                  isLiked: res.liked_by_user)
                
                photos.append(photo)
            }
            
            if lastLoadedPage == nil {
                lastLoadedPage = 1
            } else {
                lastLoadedPage! += 1
            }
            task = nil
            print(photos.count)
            NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                            object: self)
        case .failure(let error):
            print(error)
        }
    }
    
    private func createPhotosRequest(_ nextPage: String) -> URLRequest {
        // Создание URL
        var urlComponents = URLComponents(string: URL(string: "/photos", relativeTo: AuthConfiguration.standard.defaultBaseURL)!.absoluteString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: nextPage),
            URLQueryItem(name: "per_page", value: "10")
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let token = OAuth2TokenStorage().token ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        var request: URLRequest?
        
        if isLike {
            request = createDislikeRequest(id: photoId)
        }
        else {
            request = createLikeRequest(id: photoId)
        }
        
        let task = URLSession.shared.dataTask(with: request!) { data, response, error in
            DispatchQueue.main.async {
                
                // Проверяем, пришла ли ошибка
                if let error = error {
                    completion(.failure(URLSession.NetworkError.errorResponse(error)))
                    return
                }
                
                // Проверяем, что нам пришёл успешный код ответа
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(URLSession.NetworkError.customError("Не успешный код от сервера")))
                    return
                }
                
                // Поиск индекса элемента
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    // Текущий элемент
                    let photo = self.photos[index]
                    // Копия элемента с инвертированным значением isLiked.
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    // Заменяем элемент в массиве.
                    self.photos[index] = newPhoto
                    
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }
    
    private func createLikeRequest(id: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "/photos/\(id)/like", relativeTo: AuthConfiguration.standard.defaultBaseURL)!)
        request.httpMethod = "POST"
        
        let token = OAuth2TokenStorage().token ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func createDislikeRequest(id: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "/photos/\(id)/like", relativeTo: AuthConfiguration.standard.defaultBaseURL)!)
        request.httpMethod = "DELETE"
        
        let token = OAuth2TokenStorage().token ?? ""
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
}
