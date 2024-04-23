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
        guard let request = makeRequest(code: code) else {
            assertionFailure("Failed to make request")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let tokenResponseBody):
                completion(.success(tokenResponseBody.accessToken))
            case .failure(let error):
                self.lastCode = nil
                completion(.failure(error))
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

private extension OAuth2Service {
    func makeRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com"),
              let request = URLRequest.makeHTTPRequest(
                path: "/oauth/token"
                + "?client_id=\(APIConstatns.accessKey)"
                + "&&client_secret=\(APIConstatns.secretKey)"
                + "&&redirect_uri=\(APIConstatns.redirectURI)"
                + "&&code=\(code)"
                + "&&grant_type=authorization_code",
                httpMethod: "POST",
                baseURL: url)
        else {
            return nil
        }
        return request
    }
}
