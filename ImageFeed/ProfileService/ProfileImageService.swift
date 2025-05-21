//
//  ProfileImageService.swift
//  ImageFeed
//
// Сервис получение аватарки пользователя

import Foundation

enum ProfileImageServiceError: Error {
    case tokenNotFound
    case urlNotFound
}

final class ProfileImageService {
    // MARK: - Public Properties
    static let shared = ProfileImageService()
    
    // MARK: - Private Properties
    private let tokenStorage = OAuth2TokenStorage()
    private let networkClient: NetworkClient = NetworkClient()
    private let syncQueue = DispatchQueue(label: "profile-image-service-sync-queue", attributes: .concurrent)
    private var _avatarURL: String?
    private var _currentTask: URLSessionTask?
    
    private(set) var avatarURL: String? {
        get { syncQueue.sync { _avatarURL } }
        set { syncQueue.async(flags: .barrier) { [weak self] in self?._avatarURL = newValue } }
    }
    
    private var currentTask: URLSessionTask? {
        get { syncQueue.sync { _currentTask } }
        set { syncQueue.async(flags: .barrier) { [weak self] in self?._currentTask = newValue } }
    }
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        currentTask?.cancel()
        
        guard let token = tokenStorage.token else {
            print("[ProfileImageService] ❌ Error: Token not found")
            completion(.failure(ProfileImageServiceError.tokenNotFound))
            return
        }
        
        let endpoint = NetworkClient.Endpoint(
            path: "/users/\(username)",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"]
        )
        
        currentTask = networkClient.objectTask(for: endpoint) { [weak self] (result: Result<UserResult, NetworkClient.NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    if let url = userResult.profileImage?.currentUserImage {
                        self?.avatarURL = url
                        completion(.success(url))
                    } else {
                        print("[ProfileImageService] ❌ Error: URL not found")
                        completion(.failure(ProfileImageServiceError.urlNotFound))
                    }
                case .failure(let error):
                    print("[ProfileImageService] ❌ Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                self?.currentTask = nil
            }
        }
    }
    
    func clearProfileImage() {
        print("[ProfileImageService] ➡️ Clear profile image data")
        avatarURL = nil
    }
}

// MARK: - Extensions: DidChangeNotification
extension ProfileImageService {
    static let DidChangeNotification = Notification.Name("ProfileImageProviderDidChange")
}
