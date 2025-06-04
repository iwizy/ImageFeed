//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Наблюдатель ImagesListPresenter

import Foundation
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?

    // MARK: - Stub data
    var photosCountStub: Int = 0
    var photoStub: Photo = Photo(
        id: "1",
        size: CGSize(width: 100, height: 100),
        createdAt: Date(),
        welcomeDescription: "Test",
        thumbImageURL: "https://example.com/thumb.jpg",
        largeImageURL: "https://example.com/large.jpg",
        isLiked: false
    )

    // MARK: - Flags
    private(set) var didCallViewDidLoad = false
    private(set) var didCallDidReceivePhotosNotification = false
    private(set) var didCallDidTapLikeAt = false
    private(set) var photoAtIndex: Int?

    // MARK: - Protocol methods
    var photosCount: Int {
        photosCountStub
    }
    
    var didCallDidTapLike: Bool {
        return didCallDidTapLikeAt
    }

    func viewDidLoad() {
        didCallViewDidLoad = true
    }

    func didReceivePhotosNotification() {
        didCallDidReceivePhotosNotification = true
    }

    func didTapLike(at index: Int) {
        didCallDidTapLikeAt = true
        photoAtIndex = index
    }

    func photo(at index: Int) -> Photo {
        photoAtIndex = index
        return photoStub
    }
    
}
