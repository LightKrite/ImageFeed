//
//  ImageListService.swift
//  ImageFeed
//
//  Created by Egor Partenko on 26.04.2024.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let urlSession = URLSession.shared
    
    private let dateFormatter = ISO8601DateFormatter()
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    
    private var currentTask: URLSessionTask?
    
// MARK: func
    
    func fetchPhotosNextPage() {
        
        assert(Thread.isMainThread)
        
        guard currentTask == nil else { return }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard let request = makeRequest(page: nextPage) else {
            debugPrint("invalid requesr")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result <[PhotoResult], Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    if self.lastLoadedPage == nil {
                        self.lastLoadedPage = 1
                    } else {
                        self.lastLoadedPage! += 1
                    }
                    
                    let newPhotos = photoResults.map { Photo($0, date: self.dateFormatter) }
                    self.photos.append(contentsOf: newPhotos)
                    
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    func changeLike(photoID: String, isLike: Bool, complition: @escaping (Result<Void,Error>) -> Void) {
        if currentTask != nil {
            currentTask?.cancel()
        }
        
        guard let request = makeLikeRequest(photoID: photoID, isLike: isLike) else {
            debugPrint("Запрос не удался")
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<PhotoLike, Error>) in
            DispatchQueue.main.async {
                switch result {
                case.success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoID }) {
                        let photo = self.photos[index]
                        let newPhotoResult = PhotoResult(id: photo.id,
                                                         width: Int(photo.size.width),
                                                         height: Int(photo.size.height),
                                                         createdAt: photo.createdAt?.description,
                                                         description: photo.welcomeDescription,
                                                         urls: UrlsResult(full: photo.largeImageURL,
                                                                          regular: photo.regularImageURL,
                                                                          small: photo.smallImageURL,
                                                                          thumb: photo.thumbImageURL),
                                                         likedByUser: !photo.isLiked)
                        let newPhoto = Photo(newPhotoResult, date: self.dateFormatter)
                        self.photos[index] = newPhoto
                        complition(.success(()))
                    }
                    
                case.failure(let error):
                    fatalError("error like: \(error)")
                }
            
            }
        }
        self.currentTask = task
        task.resume()
    }
    
    private func makeRequest(page: Int) -> URLRequest? {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        return URLRequest.makeHTTPRequest(path: "/photos",
                                          httpMethod: "GET",
                                          queryItems: queryItems,
                                          baseURL: String(describing: APIConstatns.defaultAPIBaseURL))
    }
    
    private func makeLikeRequest(photoID: String, isLike: Bool) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/photos/\(photoID)/like",
                                   httpMethod: isLike ? "POST" : "DELETE",
                                   baseURL: String(describing: APIConstatns.defaultAPIBaseURL))
    }
    
    
}
