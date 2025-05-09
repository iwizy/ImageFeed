//
//  OAuth2Service.swift
//  ImageFeed
//
// Сервис авторизации

import Foundation

final class OAuth2Service {
    // Error Types
    enum ServiceError: LocalizedError {
        case invalidRequest
        case invalidGrant(description: String)
        case otherError(message: String)
        
        var errorDescription: String? {
            switch self {
            case .invalidRequest: return "Неверный запрос"
            case .invalidGrant(let description): return "Ошибка авторизации: \(description)"
            case .otherError(let message): return message
            }
        }
    }
    
    // MARK: - Public Properties
    static let shared = OAuth2Service()
    
    // MARK: - Private Properties
    private struct ActiveAuthRequest {
        let task: URLSessionTask
        let authCode: String
    }
    
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient
    private let baseURL = URL(string: "https://unsplash.com")!
    private var currentAuthRequest: ActiveAuthRequest?
    
    // MARK: - Initializers
    init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Public Methods
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        
        if let currentRequest = currentAuthRequest {
            if currentRequest.authCode == code {
                currentRequest.task.cancel()
                print("[OAuth2Service] ❌ Отменен предыдущий запрос для кода: \(code)")
            }
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        guard let body = makeTokenRequestBody(code: code) else {
            print("[OAuth2Service] ❌ Invalid request body")
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        let endpoint = NetworkClient.Endpoint(
            path: "/oauth/token",
            method: .post,
            baseURL: baseURL,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            body: body
        )
        
        let task = networkClient.objectTask(for: endpoint) { [weak self] (result: Result<OAuthTokenResponseBody, NetworkClient.NetworkError>) in
            DispatchQueue.main.async {
                self?.currentAuthRequest = nil
                switch result {
                case .success(let response):
                    self?.tokenStorage.storeToken(response.accessToken)
                    completion(.success(response.accessToken))
                case .failure(let error):
                    // Преобразование NetworkError в ServiceError
                    let serviceError = self?.parseNetworkError(error) ?? ServiceError.otherError(message: error.localizedDescription)
                    print("[OAuth2Service] ❌ Error: \(serviceError.localizedDescription)")
                    completion(.failure(serviceError))
                }
            }
        }
        
        currentAuthRequest = ActiveAuthRequest(task: task, authCode: code)
    }
    
    // MARK: - Private Methods
    private func makeTokenRequestBody(code: String) -> Data? {
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        return parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
    }
    
    private func parseNetworkError(_ error: NetworkClient.NetworkError) -> ServiceError {
        switch error {
        case .clientError(_, let data):
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let errorType = json["error"] as? String,
                  let description = json["error_description"] as? String else {
                return .otherError(message: "Неизвестная ошибка сервера")
            }
            return errorType == "invalid_grant" ? .invalidGrant(description: description) : .otherError(message: description)
        case .decodingError(let error):
            return .otherError(message: "Ошибка декодирования: \(error.localizedDescription)")
        case .connectionError(let error):
            return .otherError(message: "Ошибка соединения: \(error.localizedDescription)")
        default:
            return .otherError(message: "Сетевая ошибка: \(error.localizedDescription)")
        }
    }
}
