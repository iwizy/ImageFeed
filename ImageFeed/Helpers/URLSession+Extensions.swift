//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Сетевой клиент

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case noDataReceived
}

extension URLSession {
    func dataTask(
        for request: URLRequest,
        completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("[NetworkClient] Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("[NetworkClient] Ошибка: нет данных в ответе")
                completion(.failure(NetworkError.noDataReceived))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                print("[NetworkClient] Ошибка: неверный тип ответа")
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            print("[NetworkClient] Получен ответ с кодом \(response.statusCode)")
            completion(.success((data, response)))
        }
        
        return task
    }
}
