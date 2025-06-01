//
//  ProfilePresenterTests.swift
//  ImageFeed
//
//  Тесты ProfilePresenter

import XCTest
@testable import ImageFeed

final class ProfilePresenterTests: XCTestCase {

    // Проверяем, что при вызове viewDidLoad у Presenter вызывается метод updateProfileData у View
    func testViewDidLoadCallsUpdateProfileData() {
        // given
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        view.presenter = presenter

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(view.didCallUpdateProfileData, "Метод updateProfileData должен быть вызван")
    }

    // Проверяем, что при вызове viewDidLoad у Presenter вызывается метод updateAvatar у View
    func testViewDidLoadCallsUpdateAvatar() {
        // given
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenter()
        presenter.view = view
        view.presenter = presenter

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(view.didCallUpdateAvatar, "Метод updateAvatar должен быть вызван")
    }
}
