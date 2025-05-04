//
//  OAuth2Service.swift
//  ImageFeed
//

import Foundation

final class OAuth2Service {
    // MARK: - Error Types
    // Система ошибок для более понятных сообщений
    enum ServiceError: LocalizedError {
        case invalidRequest
        case invalidGrant(description: String)
        case otherError(message: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidRequest:
                return "Неверный запрос"
            case .invalidGrant(let description):
                return "Ошибка авторизации: \(description)"
            case .otherError(let message):
                return message
            }
        }
    }
    
    // Структура для отслеживания активных запросов
    private struct ActiveAuthRequest {
        let task: URLSessionTask
        let authCode: String
    }
    
    // MARK: - Configuration
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient

    private let baseURL = URL(string: "https://unsplash.com")!
    
    private init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // Отслеживание текущего запроса
    private var currentAuthRequest: ActiveAuthRequest?

    // MARK: - Main Method
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        // Обработка активных запросов
        if let currentRequest = currentAuthRequest {
            if currentRequest.authCode == code {
                currentRequest.task.cancel()
                print("[OAuth2Service] Отменен предыдущий запрос для кода: \(code)")
            }
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        // Формирование тела запроса
        guard let body = makeTokenRequestBody(code: code) else {
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        // Создание endpoint
        let endpoint = NetworkClient.Endpoint(
            path: "/oauth/token",
            method: .post,
            baseURL: baseURL,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            body: body
        )
        
        print("[OAuth2Service] Отправка запроса для кода: \(code)")
        
        let task = networkClient.objectTask(for: endpoint) { [weak self] (result: Result<OAuthTokenResponseBody, NetworkClient.NetworkError>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.currentAuthRequest = nil
                
                switch result {
                case .success(let response):
                    self.tokenStorage.storeToken(response.accessToken)
                    completion(.success(response.accessToken))
                    
                case .failure(let error):
                    // Парсинг ошибок
                    let serviceError = self.parseNetworkError(error)
                    print("[OAuth2Service] Ошибка: \(serviceError.localizedDescription)")
                    completion(.failure(serviceError))
                }
            }
        }
        
        currentAuthRequest = ActiveAuthRequest(task: task, authCode: code)
    }
    
    // MARK: - Private Helpers
    // Метод формирования тела запроса
    private func makeTokenRequestBody(code: String) -> Data? {
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        // Кодирование параметров
        var components = URLComponents()
        components.queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        guard let query = components.query else {
            print("[OAuth2Service] Не удалось создать query строку")
            return nil
        }
        
        print("[OAuth2Service] Параметры запроса: \(parameters)")
        return query.data(using: .utf8)
    }
    
    // Детальный парсинг ошибок
    private func parseNetworkError(_ error: NetworkClient.NetworkError) -> ServiceError {
        switch error {
        case .clientError(_, let data):
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let errorType = json["error"] as? String,
                  let description = json["error_description"] as? String else {
                return .otherError(message: "Неизвестная ошибка сервера")
            }
            
            if errorType == "invalid_grant" {
                return .invalidGrant(description: description)
            }
            return .otherError(message: description)
            
        case .decodingError(let error):
            return .otherError(message: "Ошибка декодирования: \(error.localizedDescription)")
            
        default:
            return .otherError(message: "Сетевая ошибка: \(error.localizedDescription)")
        }
    }
}
