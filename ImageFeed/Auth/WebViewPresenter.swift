//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Перезнтер WebView

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Public properties
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        // Создаем компоненты URL из базового адреса авторизации
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            print("Ошибка: Не удалось создать URL компоненты")
            return
        }
        
        // Добавляем обязательные параметры для OAuth запроса
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        // Проверяем и создаем итоговый URL
        guard let url = urlComponents.url else {
            print("Ошибка: Не удалось создать URL для авторизации")
            return
        }
        
        // Создаем и выполняем запрос
        
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    // MARK: - Public methods
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
}
