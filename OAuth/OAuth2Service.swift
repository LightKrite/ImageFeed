//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Egor Partenko on 16.02.2024.
//

import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    private (set) var authToken: String? {
        get { OAuth2Storage().token }
        set { OAuth2Storage().token = newValue }
    }
    
    private func makeURL(code: String) -> URLComponents {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")!
        urlComponents.queryItems = [URLQueryItem(name: "client_id", value: APIConstatns.accessKey),
                                    URLQueryItem(name: "client_secret", value: APIConstatns.secretKey),
                                    URLQueryItem(name: "redirect_uri", value: APIConstatns.redirectURI),
                                    URLQueryItem(name: "code", value: code),
                                    URLQueryItem(name: "grant_type", value: "authorization_code")]
        
        return urlComponents
    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>)-> Void) {
        
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let url = makeURL(code: code).url else {
            completion(.failure(NetworkError.badURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let fulfillCompletion: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let response = response,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if 200..<300 ~= statusCode {
                        let decoder = JSONDecoder()
                        guard let object = try? decoder.decode(OAuthTokenResponseBody.self, from: data) else {
                            fulfillCompletion(.failure(NetworkError.invalidDecoding))
                            return
                        }
                        let authToken = object.accessToken
                        self?.authToken = authToken
                        fulfillCompletion(.success(authToken))
                    }
                    else {
                        fulfillCompletion(.failure(error ?? NetworkError.httpStatusCode(statusCode)))
                        return
                    }
                }
                self?.task = nil
                self?.lastCode = nil
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
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
        case createdAt = "created_at"
    }
}
