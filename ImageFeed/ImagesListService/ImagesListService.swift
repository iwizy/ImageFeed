//
//  ImagesListService.swift
//  ImageFeed
//
//  Сервис получения списка изображений

import UIKit

final class ImagesListService {
    
    // MARK: - Public Properties
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var isFetching = false
    private var currentTask: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()
    private let networkClient: NetworkClient = NetworkClient()
    private let tokenStorage = OAuth2TokenStorage()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    
    // Очистка всех изображений
    func cleatImagesList() {
        print("[ImagesListService] ➡️ Clear images list")
        photos.removeAll()
    }
    
    // Метод получения следующей страницы изображений
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        
        guard let token = tokenStorage.token else {
            assertionFailure("[ImagesListService] ❌ No token found")
            isFetching = false
            return
        }
        
        let nextPage = lastLoadedPage + 1
        let request = NetworkClient.Endpoint(
            path: "/photos",
            method: .get,
            headers: ["Authorization": "Bearer \(token)"],
            queryItems: [
                URLQueryItem(name: "page", value: String(nextPage)),
                URLQueryItem(name: "per_page", value: "10")
            ]
        )
        
        print("[ImagesListService] Fetching page \(nextPage)")
        
        currentTask = networkClient.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], NetworkClient.NetworkError>) in
            guard let self else { return }
            self.isFetching = false
            
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { self.convert($0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    print("[ImagesListService] ✅ Loaded \(newPhotos.count) photos")
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
                
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: ❌ Failure — \(error.localizedDescription), page: \(nextPage)")
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenStorage.token else {
            assertionFailure("[ImagesListService] ❌ No token found")
            completion(.failure(NSError(domain: "NoToken", code: 401)))
            return
        }
        
        let method: NetworkClient.HTTPMethod = isLike ? .post : .delete
        let request = NetworkClient.Endpoint(
            path: "/photos/\(photoId)/like",
            method: method,
            headers: ["Authorization": "Bearer \(token)"]
        )
        
        print("[ImagesListService] \(isLike ? "POST" : "DELETE") /photos/\(photoId)/like")
        
        _ = networkClient.objectTask(for: request) { [weak self] (result: Result<LikeResult, NetworkClient.NetworkError>) in
            switch result {
            case .success(let likeResult):
                DispatchQueue.main.async {
                    self?.updatePhotoModel(with: likeResult.photo)
                    completion(.success(()))
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            case .failure(let error):
                print("[ImagesListService.changeLike] ❌ Like change error: \(error.localizedDescription), photoId: \(photoId), method: \(method)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func updatePhotoModel(with updatedPhoto: PhotoResult) {
        let updated = convert(updatedPhoto)
        if let index = photos.firstIndex(where: { $0.id == updated.id }) {
            photos[index] = updated
        }
    }
    
    private func convert(_ result: PhotoResult) -> Photo {
        let size = CGSize(width: result.width, height: result.height)
        let createdAtDate = result.createdAt.flatMap { dateFormatter.date(from: $0) }
        
        return Photo(
            id: result.id,
            size: size,
            createdAt: createdAtDate,
            welcomeDescription: result.description,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
}
