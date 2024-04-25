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
    case decodeError
}

extension URLSession {
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
            
            let fulfillCompletion: (Result<T, Error>) -> Void = { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            let task = dataTask(with: request, completionHandler: { data, response, error in
                if let data = data,
                   let response = response,
                   let statusCode = (response as? HTTPURLResponse)?.statusCode
                {
                    if 200 ..< 300 ~= statusCode {
                        do{
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase
                            let decodedObject = try decoder.decode(T.self, from: data)
                            fulfillCompletion(.success(decodedObject))
                        } catch {
                            fulfillCompletion(.failure(NetworkError.decodeError))
                            debugPrint("\(String(describing: T.self)) [dataTask:] - Network Error")
                        }
                    } else {
                        fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                        debugPrint("\(String(describing: T.self)) [dataTask:] - Network Error \(statusCode)" )
                    }
                } else if let error = error {
                    fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
                    debugPrint("\(String(describing: T.self)) [dataTask:] - Network Error \(error)" )
                } else {
                    fulfillCompletion(.failure(NetworkError.urlSessionError))
                    debugPrint("\(String(describing: T.self)) [dataTask:] - Network Error")

                }
            })
            task.resume()
            return task
        }
    
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
                let response = response,
                let statusCode = ( response as? HTTPURLResponse)?.statusCode
            {
                
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                    debugPrint("\(String(describing: self)) [dataTask:] - Network Error \(statusCode)" )
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
                debugPrint("\(String(describing: self)) [dataTask:] - Network Error \(error)" )
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
                debugPrint("\(String(describing: self)) [dataTask:] - Network Error")
            }
        }
        task.resume()
        return task
    }

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
