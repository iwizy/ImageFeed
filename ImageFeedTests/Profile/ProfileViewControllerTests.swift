//
//  ProfileViewControllerTests.swift
//  ImageFeed
//
//  Тест ProfileViewController

import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {

    // Проверяем, что при вызове updateProfileData у вью вызывается соответствующий метод отображения данных профиля
    func testUpdateProfileDataCallsViewMethod() {
        // given
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        view.presenter = presenter
        presenter.view = view

        // when
        view.presenter?.view?.updateProfileData()

        // then
        XCTAssertTrue(view.didCallUpdateProfileData)
    }

    // Проверяем, что при вызове updateAvatar у вью вызывается соответствующий метод обновления аватара
    func testUpdateAvatarCallsViewMethod() {
        // given
        let view = ProfileViewControllerSpy()
        let presenter = ProfilePresenterSpy()
        view.presenter = presenter
        presenter.view = view

        // when
        view.presenter?.view?.updateAvatar()

        // then
        XCTAssertTrue(view.didCallUpdateAvatar)
    }

    // Проверяем, что при нажатии на кнопку выхода вызывается метод exitProfile у презентера
    func testDidTapLogoutCallsExitProfileOnPresenter() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter

        // when
        viewController.loadViewIfNeeded() // инициализация UI
        viewController.perform(#selector(viewController.didTapLogoutButton)) // эмуляция нажатия

        // эмуляция подтверждения выхода пользователем
        viewController.presenter?.exitProfile()

        // then
        XCTAssertTrue(presenter.didCallExitProfile, "Метод exitProfile() должен быть вызван при подтверждении выхода")
    }
}
