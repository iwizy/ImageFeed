//
//  URLSession+Extensions.swift
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
    case invalidTokenFormat // Неверный формат токена
}

extension URLSession {
    // Выполняет сетевой запрос и возвращает результат в виде Data
    func fetchData(
        for request: URLRequest,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> URLSessionTask {
        // Обеспечиваем вызов completion на главном потоке
        let completionOnMainQueue: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        // Создаем и настраиваем задачу URLSession
        let task = dataTask(with: request) { data, response, error in
            // Проверяем наличие данных и корректный HTTP-статус
            guard let data = data,
                  let response = response as? HTTPURLResponse else {
                if let error = error {
                    print("[NetworkClient] Ошибка запроса: \(error.localizedDescription)")
                    completionOnMainQueue(.failure(error))
                } else {
                    print("[NetworkClient] Ошибка: неизвестная ошибка URLSession (нет данных и ошибки)")
                    completionOnMainQueue(.failure(NetworkError.urlSessionError))
                }
                return
            }
            
            // Проверяем статус-код (200-299)
            if (200..<300).contains(response.statusCode) {
                // Декодирование токена из данных
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    print("[NetworkClient] Токен успешно декодирован")
                    completionOnMainQueue(.success(tokenResponse.accessToken))
                } catch {
                    print("[NetworkClient] Ошибка декодирования токена: \(error.localizedDescription)")
                    completionOnMainQueue(.failure(NetworkError.decodingError(error)))
                }
            } else {
                if response.statusCode >= 300 {
                    let responseBody = String(data: data, encoding: .utf8) ?? "Не удалось преобразовать данные"
                    print("""
                            [NetworkClient] Ошибка Unsplash API:
                            - Код статуса: \(response.statusCode)
                            - Тело ответа: \(responseBody)
                            """)
                }
                print("[NetworkClient] Ошибка: статус-код \(response.statusCode)")
                completionOnMainQueue(.failure(NetworkError.httpStatusCode(response.statusCode)))
            }
        }
        
        // Запускаем задачу
        task.resume()
        
        // Возвращаем задачу для возможного управления (отмена и т.д.)
        return task
    }
    
    // Приватный метод для декодирования токена
    private func decodeToken(from data: Data) throws -> String {
        struct TokenResponse: Decodable {
            let authToken: String
        }
        
        let decoder = JSONDecoder()
        do {
            let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
            return tokenResponse.authToken
        } catch {
            throw NetworkError.decodingError(error) // Проброс ошибки декодирования
        }
    }
}
