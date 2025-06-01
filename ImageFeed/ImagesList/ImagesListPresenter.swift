//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Презентер ленты фотографий

import UIKit

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ImagesListViewProtocol?
    var photos: [Photo] = []
    var photosCount: Int {
        photos.count
    }
    
    // MARK: - Private Properties
    private let imagesListService = ImagesListService.shared
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.didReceivePhotosNotification()
        }
    }
    
    // MARK: - Public Methods
    func didReceivePhotosNotification() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count

        guard newCount > oldCount else {
            photos = newPhotos
            view?.reloadData() 
            return
        }

        photos = newPhotos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        view?.insertRows(at: indexPaths)
    }

    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func didTapLike(at index: Int) {
        guard index < photos.count else { return }

        let photo = photos[index]
        view?.showLoadingIndicator()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()

                switch result {
                case .success:
                    let updatedPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos[index] = updatedPhoto
                    self.view?.updateRow(at: index)
                case .failure:
                    self.view?.showLikeError()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
