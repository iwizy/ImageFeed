//
//  ImagesListPresenterTests.swift
//  ImageFeed
//
//  Тесты ImagesListPresenter

import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {

    // Проверяем, что метод viewDidLoad был вызван у презентера
    func testViewDidLoad_CallsViewDidLoad() {
        // given
        let presenter = ImagesListPresenterSpy()

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(presenter.didCallViewDidLoad, "Метод viewDidLoad должен быть вызван")
    }

    // Проверяем, что метод didReceivePhotosNotification был вызван у презентера
    func testDidReceivePhotosNotification_CallsNotificationHandler() {
        // given
        let presenter = ImagesListPresenterSpy()

        // when
        presenter.didReceivePhotosNotification()

        // then
        XCTAssertTrue(presenter.didCallDidReceivePhotosNotification, "Метод didReceivePhotosNotification должен быть вызван")
    }

    // Проверяем, что при вызове didTapLike(at:) флаг устанавливается и индекс передаётся корректно
    func testDidTapLike_CallsLikeHandler() {
        // given
        let presenter = ImagesListPresenterSpy()

        // when
        presenter.didTapLike(at: 0)

        // then
        XCTAssertTrue(presenter.didCallDidTapLike, "Метод didTapLike(at:) должен быть вызван")
        XCTAssertEqual(presenter.photoAtIndex, 0, "Метод должен быть вызван с индексом 0")
    }

    // Проверяем, что метод photo(at:) возвращает ожидаемый объект-заглушку
    func testPhoto_ReturnsStub() {
        // given
        let presenter = ImagesListPresenterSpy()

        // when
        let photo = presenter.photo(at: 0)

        // then
        XCTAssertEqual(photo.id, "1", "photo(at:) должен вернуть заглушку с id == 1")
    }

    // Проверяем, что свойство photosCount возвращает заданное stub-значение
    func testPhotosCount_ReturnsStubCount() {
        // given
        let presenter = ImagesListPresenterSpy()
        presenter.photosCountStub = 5

        // when
        let count = presenter.photosCount

        // then
        XCTAssertEqual(count, 5, "photosCount должен вернуть установленное значение")
    }
}
