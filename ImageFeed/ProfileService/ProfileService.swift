//
//  ProfileService.swift
//  ImageFeed
//
// Сервис получения данных профиля пользователя

import Foundation

final class ProfileService {
    // MARK: - Public Properties
    static let shared = ProfileService()

    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient = NetworkClient()
    private let syncQueue = DispatchQueue(label: "profile-service-sync-queue", attributes: .concurrent)
    private var _profile: Profile?
    private var _currentTask: URLSessionTask?
    
    private(set) var profile: Profile? {
        get { syncQueue.sync { _profile } }
        set { syncQueue.async(flags: .barrier) { [weak self] in self?._profile = newValue } }
    }
    
    private var currentTask: URLSessionTask? {
        get { syncQueue.sync { _currentTask } }
        set { syncQueue.async(flags: .barrier) { [weak self] in self?._currentTask = newValue } }
    }

    // MARK: - Initializers
    private init() {}

    // MARK: - Private Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        print("[ProfileService] Using token: \(token)")
        assert(Thread.isMainThread)
        currentTask?.cancel()
        
        let endpoint = NetworkClient.Endpoint(
            path: "/me",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )
        
        currentTask = networkClient.objectTask(for: endpoint) { [weak self] (result: Result<ProfileResult, NetworkClient.NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    let profile = Profile(ProfileResult: profileResult)
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService] ❌ Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.currentTask = nil
            }
        }
    }
}
