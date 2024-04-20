//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Egor Partenko on 18.04.2024.
//

import Foundation


final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let urlSession = URLSession.shared
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    
    
    func fetchProfileImageURL(username:String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        var request = URLRequest.makeHTTPRequest(path: "/users/\(username)", httpMethod: "GET", baseURL: APIConstatns.defaultAPIBaseURL)
        request.setValue("Bearer \(OAuth2Storage().token!)", forHTTPHeaderField: "Authorization")
        
        let completionOnMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.profileImage["large"]
                completionOnMainThread(.success(self.avatarURL!))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL" : self.avatarURL!])
            case .failure(let error):
                self.task = nil
                completionOnMainThread(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
}


extension ProfileImageService {
  private struct UserResult: Codable {
      var profileImage: [String: String]
    }
}
