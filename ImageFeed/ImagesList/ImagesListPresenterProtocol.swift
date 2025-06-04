//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Протокол ImagesListPresenter


import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photosCount: Int { get }
    func photo(at index: Int) -> Photo
    func viewDidLoad()
    func didReceivePhotosNotification()
    func didTapLike(at index: Int)
}
