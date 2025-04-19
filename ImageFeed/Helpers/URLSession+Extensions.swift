//
//  NetworkClient.swift
//  ImageFeed
//
//  Сетевой клиент

import Foundation

// Перечисление возможных сетевых ошибок
enum NetworkError: Error {
    case httpStatusCode(Int) // Ошибка HTTP статус-кода (выходящего за диапазон 200-299)
    case urlRequestError(Error) // Ошибка при создании или выполнении URLRequest
    case urlSessionError // Неизвестная ошибка URLSession
    case noDataReceived // Ошибка отсутствия данных в ответе
    case decodingError(Error) // Ошибка декодирования данных
}

extension URLSession {
    // Выполняет сетевой запрос и возвращает результат в виде Data
    func fetchData(
        for request: URLRequest,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionTask {
        // Обеспечиваем вызов completion на главном потоке
        let completionOnMainQueue: (Result<Data, NetworkError>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        // Создаем и настраиваем задачу URLSession
        let task = dataTask(with: request) { data, response, error in
            // Обрабатываем три возможных сценария:
            
            // Успешный ответ с данными
            if let data = data,
               let response = response as? HTTPURLResponse {
                
                // Проверяем валидный диапазон статус-кодов (200-299)
                if (200..<300).contains(response.statusCode) {
                    completionOnMainQueue(.success(data))
                } else {
                    // Неуспешный статус-код
                    completionOnMainQueue(.failure(.httpStatusCode(response.statusCode)))
                }
            }
            // Ошибка запроса
            else if let error = error {
                completionOnMainQueue(.failure(.urlRequestError(error)))
            }
            // Неизвестная ошибка (нет данных и нет ошибки)
            else {
                completionOnMainQueue(.failure(.urlSessionError))
            }
        }
        
        // Запускаем задачу
        task.resume()
        
        // Возвращаем задачу для возможного управления (отмена и т.д.)
        return task
    }
}
