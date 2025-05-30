//
//  WebViewPresenter.swift
//  ImageFeed
//
//  WebView Presenter

import Foundation
import WebKit


enum WebViewConstants {
    // Базовый URL для авторизации через Unsplash OAuth
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    func code(from url: URL) -> String? {
        // Проверяем все необходимые условия для извлечения кода:
        guard
            let urlComponents = URLComponents(string: url.absoluteString), // Должны быть компоненты URL
            urlComponents.path == "/oauth/authorize/native", // Путь должен соответствовать OAuth callback
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) // Должен присутствовать query-параметр "code"
        else {
            return nil
        }
        
        return codeItem.value
    }
    
    weak var view: WebViewViewControllerProtocol?
    
    
    func viewDidLoad() {
        // Создаем компоненты URL из базового адреса авторизации
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
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
        let request = URLRequest(url: url)
        view?.load(request: request)
        didUpdateProgressValue(0)
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
