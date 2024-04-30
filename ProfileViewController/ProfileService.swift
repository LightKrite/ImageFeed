//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Egor Partenko on 08.04.2024.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private (set) var profile: ProfileResult?
    private var task:URLSessionTask?
    private var lastToken: String?
    
    
    func fetchProfile(token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void ) {
        assert(Thread.isMainThread)
        if lastToken == token { return }
        task?.cancel()
        lastToken = token
        
        guard var request = URLRequest.makeHTTPRequest(path: "/me",
                                                       httpMethod: "GET",
                                                       baseURL: String(describing: APIConstatns.defaultAPIBaseURLString)) else {
            assertionFailure("Failed to make HTTP request")
            completion(.failure(NetworkError.invalidRequest))
            debugPrint("\(String(describing: ProfileResult.self)) [dataTask:] - Network Error")
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                self.profile = profileResult
                completion(.success(profileResult))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                debugPrint("\(String(describing: ProfileResult.self)) [dataTask:] - Network Error \(error)" )
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}
