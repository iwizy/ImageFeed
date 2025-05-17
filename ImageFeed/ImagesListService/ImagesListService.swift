//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 15.05.2025.
//

import UIKit


final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var isFetching = false
    private var currentTask: URLSessionTask?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    private let networkClient: NetworkClient
    private let tokenStorage = OAuth2TokenStorage()

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

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
            guard let self = self else { return }
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
                print("[ImagesListService] ❌ Network error: \(error.localizedDescription)")
            }
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
