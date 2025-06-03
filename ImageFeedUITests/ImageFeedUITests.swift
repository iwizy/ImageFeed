//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//

import XCTest

class Image_FeedUITests: XCTestCase {
    // Экземпляр приложения, с которым будут выполняться UI-тесты
    private let app = XCUIApplication()

    // Метод настройки, вызывается перед каждым тестом
    override func setUpWithError() throws {
        continueAfterFailure = false // Прерывать тест при первой же ошибке
        app.launch() // Запуск приложения
    }

    // MARK: - Тест авторизации
    func testAuth() throws {
        // Нажимаем кнопку "Authenticate" на главном экране
        app.buttons["Authenticate"].tap()
        
        // Ищем WebView с идентификатором "UnsplashWebView"
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")

        // Находим поле для логина
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        
        // Вводим логин
        loginTextField.tap()
        loginTextField.typeText("__")
        webView.swipeUp()
        
        // Находим поле пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        
        // Вставляем пароль через буфер обмена (избегаем проблем с пропущенными символами)
        passwordTextField.tap()
        UIPasteboard.general.string = "__"
        passwordTextField.doubleTap() // Открываем меню вставки
        app.menuItems["Paste"].tap() // Вставляем пароль
        webView.swipeUp()
        
        // Нажимаем кнопку "Login"
        webView.buttons["Login"].tap()
        
        // Проверяем, загрузилась ли таблица с ячейками (фид)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Фид не загрузился после логина")
    }

    // MARK: - Тест ленты и лайка
    func testFeed() throws {
        let tablesQuery = app.tables

        // Находим первую ячейку и скроллим, чтобы активировать таблицу
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка не загрузилась")
        firstCell.swipeUp()
        sleep(1)

        // Находим вторую ячейку (index 1) для теста лайка
        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Вторая ячейка не найдена")

        // Находим первую кнопку в ячейке (предположительно кнопку лайка)
        let likeButton = cellToLike.buttons.firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3), "Кнопка лайка не найдена")

        // Ставим и убираем лайк
        likeButton.tap()
        sleep(1)
        likeButton.tap()
        sleep(1)

        // Переход на экран с полноразмерным изображением
        cellToLike.tap()
        sleep(1)

        // Проверяем наличие изображения
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5), "Полноразмерное изображение не найдено")

        // Выполняем zoom in/out
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        // Возвращаемся назад
        let backButton = app.buttons["nav_button_back"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
    }

    // MARK: - Тест профиля и выхода
    func testProfile() throws {
        sleep(3) // Ожидание загрузки интерфейса
        app.tabBars.buttons.element(boundBy: 1).tap() // Переход на вкладку профиля
       
        // Проверка отображения имени и логина
        XCTAssertTrue(app.staticTexts["nameLabel"].exists, "Имя не отображается")
        XCTAssertTrue(app.staticTexts["loginNameLabel"].exists, "Логин не отображается")
        
        // Тап по кнопке выхода
        app.buttons["logoutButton"].tap()
        
        // Подтверждение выхода
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
