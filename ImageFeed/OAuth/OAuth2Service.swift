//
//  OAuth2Service.swift
//  ImageFeed
//
//  Класс сервиса авторизации

import Foundation

final class OAuth2Service {
    
    enum NetworkError: Error {
        case invalidRequest
        case urlSessionError
    }
    
    // MARK: Singleton
    // Общий экземпляр сервиса (Singleton)
    static let shared = OAuth2Service()
    
    // MARK: Dependencies
    // Хранилище для токенов OAuth 2.0
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: Initialization
    // Приватный инициализатор для реализации паттерна Singleton
    private init() {}
    
    // MARK: Request Construction
    
    // Создает URLRequest для получения OAuth токена
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        // Базовый URL Unsplash API
        let baseUrl = "https://unsplash.com"
        // Путь для запроса токена
        let path = "/oauth/token"
        
        // Создаем компоненты URL
        guard var urlComponents = URLComponents(string: baseUrl) else {
            print("[OAuth2Service] Ошибка: Неверный базовый URL")
            return nil
        }
        
        // Устанавливаем путь
        urlComponents.path = path
        
        // Добавляем параметры запроса согласно OAuth 2.0 спецификации
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        // Проверяем итоговый URL
        guard let url = urlComponents.url else {
            print("[OAuth2Service] Ошибка: Не удалось создать URL из компонентов")
            return nil
        }
        
        // Создаем и настраиваем запрос
        var request = URLRequest(url: url)
        request.httpMethod = "POST" // Устанавливаем метод POST
        
        return request
    }
    
    // MARK: Public Methods
    
    // Получает OAuth токен по коду авторизации
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Создаем запрос
        guard let request = makeOAuthTokenRequest(code: code) else {
            // Если не удалось создать запрос, завершаем с ошибкой
            print("[OAuth2Service] Не удалось создать запрос")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        // Создаем и запускаем задачу URLSession
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // Обрабатываем ошибку сети
            if let error = error {
                print("[OAuth2Service] Сетевая ошибка: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Проверяем наличие данных
            guard let data = data else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            
            do {
                // Парсим ответ сервера
                let responseData = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                let accessToken = responseData.accessToken
                
                // Сохраняем токен в хранилище
                self?.tokenStorage.storeToken(accessToken)
                
                // Возвращаем успешный результат
                completion(.success(accessToken))
            } catch {
                // Обрабатываем ошибку декодирования
                print("[OAuth2Service] Ошибка декодирования: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        // Запускаем задачу
        task.resume()
    }
    
}
