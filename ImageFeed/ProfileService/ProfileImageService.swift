//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 28.04.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient = NetworkClient()
    
    private let syncQueue = DispatchQueue(label: "profile-image-service-sync-queue", attributes: .concurrent)
    private var _avatarURL: String?
    private var _currentTask: URLSessionTask?
    
    private(set) var avatarURL: String? {
        get {
            syncQueue.sync(flags: .barrier) { _avatarURL }
        }
        set {
            syncQueue.async(flags: .barrier) { [weak self] in
                self?._avatarURL = newValue
            }
        }
    }
    
    private var currentTask: URLSessionTask? {
        get {
            syncQueue.sync(flags: .barrier) { _currentTask }
        }
        set {
            syncQueue.async(flags: .barrier) { [weak self] in
                self?._currentTask = newValue
            }
        }
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        currentTask?.cancel()
        
        guard let token = tokenStorage.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
            return
        }
        
        let endpoint = NetworkClient.Endpoint(
            path: "/users/\(username)",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )
        
        currentTask = networkClient.request(endpoint) { [weak self] (result: Result<UserResult, NetworkClient.NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    if let smallImageURL = userResult.profileImage?.currentUserImage {
                        self?.avatarURL = smallImageURL
                        completion(.success(smallImageURL))
                    } else {
                        completion(.failure(NSError(domain: "ProfileImageService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Profile image URL not found"])))
                    }
                    self?.currentTask = nil
                case .failure(let networkError):
                    let error: Error
                    switch networkError {
                    case .clientError(let code, let data):
                        error = NSError(domain: "NetworkError", code: code, userInfo: [
                            NSLocalizedDescriptionKey: "Client error \(code)",
                            "ResponseData": data as Any
                        ])
                    case .decodingError(let decodingError):
                        error = decodingError
                    case .connectionError(let connectionError):
                        error = connectionError
                    default:
                        error = networkError
                    }
                    completion(.failure(error))
                    self?.currentTask = nil
                }
            }
        }
    }
}

extension ProfileImageService {
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
}
