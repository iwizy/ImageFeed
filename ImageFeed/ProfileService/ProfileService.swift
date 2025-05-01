//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 28.04.2025.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient = NetworkClient()
    
    private let syncQueue = DispatchQueue(label: "profile-service-sync-queue", attributes: .concurrent)
    private var _profile: Profile?
    private var _currentTask: URLSessionTask?
    
    // Храним сразу Profile
    private(set) var profile: Profile? {
        get {
            syncQueue.sync(flags: .barrier) { _profile }
        }
        set {
            syncQueue.async(flags: .barrier) { [weak self] in
                self?._profile = newValue
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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        currentTask?.cancel()
        
        let endpoint = NetworkClient.Endpoint(
            path: "/me",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )
        
        currentTask = networkClient.request(endpoint) { [weak self] (result: Result<ProfileResult, NetworkClient.NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    let profile = Profile(ProfileResult: profileResult)
                    self?.profile = profile  // Сохраняем уже преобразованный Profile
                    completion(.success(profile))
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
