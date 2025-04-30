//
//  OAuth2Service.swift
//  ImageFeed
//

import Foundation

final class OAuth2Service {
    // MARK: - Inner Types
    enum ServiceError: Error {
        case invalidRequest
        case failedToGetToken(description: String)
    }
    
    private struct ActiveAuthRequest {
        let task: URLSessionTask
        let authCode: String
    }
    
    // MARK: - Properties
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient
    
    private init(networkClient: NetworkClient = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private var currentAuthRequest: ActiveAuthRequest?
    
    // MARK: - Public Methods
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if let currentRequest = currentAuthRequest {
            if currentRequest.authCode == code {
                currentRequest.task.cancel()
                print("[OAuth2Service] Cancelled previous request")
            } else {
                completion(.failure(ServiceError.invalidRequest))
                return
            }
        }
        
        guard let body = makeTokenRequestBody(code: code) else {
            completion(.failure(ServiceError.invalidRequest))
            return
        }
        
        let task = networkClient.post(
            path: "/oauth/token",
            baseURL: URL(string: "https://unsplash.com"),
            body: body,
            headers: ["Content-Type": "application/json"],
            completion: { [weak self] (result: Result<OAuthTokenResponseBody, NetworkClient.NetworkError>) in
                guard let self = self else { return }
                
                defer {
                    DispatchQueue.main.async {
                        self.currentAuthRequest = nil
                    }
                }
                
                switch result {
                case .success(let tokenResponse):
                    self.tokenStorage.storeToken(tokenResponse.accessToken)
                    completion(.success(tokenResponse.accessToken))
                    
                case .failure(let error):
                    completion(.failure(ServiceError.failedToGetToken(description: error.localizedDescription)))
                }
            }
        )
        
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
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}
