//
//  OAuth2Service.swift
//  ImageFeed
//
//  Сервис авторизации

import Foundation

final class OAuth2Service {
    // Типы ошибок сервиса
    enum NetworkError: Error {
        case invalidRequest       // Некорректный запрос
        case decodingError(Error) // Ошибка декодирования
        case httpStatusCode(Int) // Ошибка HTTP-статуса (включая 300+)
    }
    
    static let shared = OAuth2Service()  // Синглтон
    private let tokenStorage = OAuth2TokenStorage()
    
    // Трекер активного запроса
    private struct ActiveAuthRequest {
        let task: URLSessionTask
        let authCode: String
    }
    private var currentAuthRequest: ActiveAuthRequest?
    
    private init() {}  // Приватный инициализатор
    
    // MARK: - Обработка ответа
    private func handleOAuthResponse(
        data: Data,
        response: HTTPURLResponse,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            // Проверяем успешные статусы (200-299)
            if (200..<300).contains(response.statusCode) {
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.storeToken(tokenResponse.accessToken)
                    print("[OAuth2Service] Токен успешно получен и сохранён")
                    completion(.success(tokenResponse.accessToken))
                } catch {
                    print("[OAuth2Service] Ошибка декодирования токена: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            } else {
                let responseBody = String(data: data, encoding: .utf8) ?? "Не удалось преобразовать данные"
                print("""
                    [OAuth2Service] Ошибка API:
                    - Код статуса: \(response.statusCode)  // Сюда попадают 300+, 400+, 500+
                    - Тело ответа: \(responseBody)
                    """)
                
                // Пробрасываем ошибку с кодом статуса
                completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
            }
        }
    }
    
    // MARK: - Создание запроса
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let baseUrl = "https://unsplash.com"
        let path = "/oauth/token"
        
        guard var urlComponents = URLComponents(string: baseUrl) else {
            print("[OAuth2Service] Ошибка: Неверный базовый URL")
            return nil
        }
        
        urlComponents.path = path
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            print("[OAuth2Service] Ошибка: Не удалось создать URL из компонентов")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Основной метод
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Проверка дублирующихся запросов
        if let currentRequest = currentAuthRequest {
            if currentRequest.authCode == code {
                currentRequest.task.cancel()
                print("[OAuth2Service] Отменён предыдущий запрос с тем же authCode")
            } else {
                print("[OAuth2Service] Уже выполняется запрос с другим authCode")
                completion(.failure(NetworkError.invalidRequest))
                return
            }
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(for: request) { [weak self] (result: Result<(Data, HTTPURLResponse), Error>) in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.currentAuthRequest = nil
                }
            }
            
            switch result {
            case .success(let (data, response)):
                print("[OAuth2Service] Получен ответ от сервера")
                // Здесь вызывается обработчик, где проверяются статусы 300+
                self.handleOAuthResponse(data: data, response: response, completion: completion)
            case .failure(let error):
                print("[OAuth2Service] Ошибка сети: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        currentAuthRequest = ActiveAuthRequest(task: task, authCode: code)
        task.resume()
    }
}
