//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Egor Partenko on 18.04.2024.
//

import Foundation


final class ProfileImageService {
    
    private struct UserResult: Codable {
        let profileImage: ProfileImage
    }
    
    private struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let urlSession = URLSession.shared
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private let oAuthStorage = OAuth2Storage()
    
    func fetchProfileImageURL(username:String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard task == nil else { return }
        
        guard var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET"),
              let token = oAuthStorage.token else {
            completion(.failure(NetworkError.invalidRequest))
            debugPrint("\(String(describing: self)) [dataTask:] - Network Error")

            assertionFailure("Failed to make HTTP request")
            return
        }
        request.setValue("Bearer \(OAuth2Storage().token!)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                completion(.success(user.profileImage.large))

                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL" : user.profileImage.large])
                self.avatarURL = user.profileImage.large
            case .failure(let error):
                completion(.failure(error))
                debugPrint("\(String(describing: UserResult.self)) [dataTask:] - Network Error \(error)")

            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}


