//
//  ImagesListViewSpy.swift
//  ImageFeedTests
//
// Наблюдатель ImagesListView

import Foundation
@testable import ImageFeed

final class ImagesListViewSpy: ImagesListViewProtocol {
    private(set) var didCallInsertRows = false
    private(set) var insertedIndexPaths: [IndexPath] = []

    private(set) var didCallReloadData = false
    private(set) var didCallUpdateRow = false
    private(set) var updatedRowIndex: Int?

    private(set) var didCallShowLoading = false
    private(set) var didCallHideLoading = false
    private(set) var didCallShowLikeError = false

    func insertRows(at indexPaths: [IndexPath]) {
        didCallInsertRows = true
        insertedIndexPaths = indexPaths
    }

    func reloadData() {
        didCallReloadData = true
    }

    func updateRow(at index: Int) {
        didCallUpdateRow = true
        updatedRowIndex = index
    }

    func showLoadingIndicator() {
        didCallShowLoading = true
    }

    func hideLoadingIndicator() {
        didCallHideLoading = true
    }

    func showLikeError() {
        didCallShowLikeError = true
    }
}
