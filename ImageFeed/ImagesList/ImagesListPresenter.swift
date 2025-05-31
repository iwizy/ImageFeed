//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Презентер ленты фотографий

import UIKit


protocol ImagesListViewProtocol: AnyObject {
    func insertRows(at indexPaths: [IndexPath])
    func reloadData()
}

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    func photo(at index: Int) -> Photo
    func viewDidLoad()
    func didReceivePhotosNotification()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
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
    
    func didReceivePhotosNotification() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count

        guard oldCount != newCount else { return }
        
        photos = newPhotos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        view?.insertRows(at: indexPaths)
    }

    var photosCount: Int {
        photos.count
    }

    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
