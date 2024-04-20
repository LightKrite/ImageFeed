//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Egor Partenko on 16.02.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    private (set) var authToken: String? {
        get {
            return OAuth2Storage().token
        }
        set {
            OAuth2Storage().token = newValue
        }
    }
    
//    private func makeURL(code: String) -> URLComponents {
//        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")!
//        urlComponents.queryItems = [URLQueryItem(name: "client_id", value: APIConstatns.accessKey),
//                                    URLQueryItem(name: "client_secret", value: APIConstatns.secretKey),
//                                    URLQueryItem(name: "redirect_uri", value: APIConstatns.redirectURI),
//                                    URLQueryItem(name: "code", value: code),
//                                    URLQueryItem(name: "grant_type", value: "authorization_code")]
//
//        return urlComponents
//    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>)-> Void) {
        
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = authTokenRequest(code: code)
        let completionOnMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completionOnMainThread(.success(authToken))
                self.task = nil
            case .failure(let error):
                completionOnMainThread(.failure(error))
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}

private struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
//    enum CodingKeys: String, CodingKey {
//        case accessToken = "access_token"
//        case tokenType = "token_type"
//        case scope = "scope"
//        case createdAt = "created_at"
//    }
}

extension OAuth2Service {
    
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(APIConstatns.accessKey)"
            + "&&client_secret=\(APIConstatns.secretKey)"
            + "&&redirect_uri=\(APIConstatns.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!)
    }
}
