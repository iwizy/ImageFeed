//
//  ImagesListViewProtocol.swift
//  ImageFeed
//
//  Протокол ImagesListView

import Foundation

protocol ImagesListViewProtocol: AnyObject {
    func insertRows(at indexPaths: [IndexPath])
    func reloadData()
    func updateRow(at index: Int)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showLikeError()
}
