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
    case urlSessionError
    case invalidRequest
}

extension URLSession {
    
    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    guard let object = try? decoder.decode(T.self, from: data) else {
                        completion(.failure(NetworkError.invalidDecoding))
                        return
                    }
                    completion(.success(object))
                }
                else {
                    completion(.failure(error ?? NetworkError.httpStatusCode(statusCode)))
                    return
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
        baseURL: URL
    ) -> URLRequest {
        guard let url = URL(string: path, relativeTo: baseURL) else {fatalError("Failed to create URL")}
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}
