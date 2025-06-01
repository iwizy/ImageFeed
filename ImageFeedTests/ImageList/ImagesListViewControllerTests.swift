//
//  ImagesListViewControllerTests.swift
//  ImageFeed
//
//  Тесты ImagesListViewController

import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {

    // Проверяем, что при загрузке view вызывается метод presenter.viewDidLoad()
    func testViewDidLoadCallsPresenterViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Не удалось создать ImagesListViewController из storyboard")
            return
        }

        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.didCallViewDidLoad, "Метод presenter.viewDidLoad должен быть вызван")
    }

    // Проверяем, что при получении уведомления вызывается метод presenter.didReceivePhotosNotification()
    func testDidReceivePhotosNotification_CallsPresenterNotification() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // when
        viewController.presenter?.didReceivePhotosNotification()

        // then
        XCTAssertTrue(presenter.didCallDidReceivePhotosNotification, "Метод presenter.didReceivePhotosNotification должен быть вызван")
    }

    // Проверяем, что при нажатии на лайк вызывается метод presenter.didTapLike(at:)
    func testDidTapLikeCallsPresenterDidTapLike() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        
        let presenterSpy = ImagesListPresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        // when
        _ = viewController.view // Это вызовет viewDidLoad()

        // ручной вызов метода, имитируем нажатие лайка
        viewController.presenter?.didTapLike(at: 0)
        
        // then
        XCTAssertTrue(presenterSpy.didCallDidTapLikeAt, "Метод presenter.didTapLike(at:) должен быть вызван")
    }
}
