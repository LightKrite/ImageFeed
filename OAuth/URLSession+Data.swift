//
//  URLSession+Data.swift
//  ImageFeed
//
//  Created by Egor Partenko on 21.03.2024.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case invalidDecoding
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError(Error)
    case invalidRequest
}



extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError(error)))
                }
            }
            
            if let response = response as? HTTPURLResponse {
                if !(200..<300 ~= response.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    }
                }
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(T.self, from: data)
                    
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.urlSessionError(error)))
                    }
                }
            }
        }
        return task
    }
    
    
//
//    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
//
//        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
//            DispatchQueue.main.async {
//                completion(result)
//            }
//        }
//
//        let task = dataTask(with: request, completionHandler: { data, response, error in
//            if let data = data,
//               let response = response,
//               let statusCode = (response as? HTTPURLResponse)?.statusCode {
//                if 200 ..< 300 ~= statusCode {
//                    fulfillCompletionOnMainThread(.success(data))
//                } else {
//                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
//                }
//            } else if let error = error {
//                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
//            } else {
//                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
//            }
//        })
//
//        return task
//
//    }
}

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL = APIConstatns.defaultAPIBaseURL
    ) -> URLRequest? {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            assertionFailure("Failed to make url")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}
