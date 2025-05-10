//
//  WebViewViewController.swift
//  ImageFeed
//
//  Класс webview контроллера

import UIKit
import WebKit

// Константы для работы с WebView
enum WebViewConstants {
    // Базовый URL для авторизации через Unsplash OAuth
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// Протокол для обработки событий авторизации
protocol WebViewViewControllerDelegate: AnyObject {
    // Вызывается при успешной авторизации
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    // Вызывается при отмене авторизации
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// Контроллер для отображения веб-интерфейса авторизации через OAuth 2.0
final class WebViewViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Public Properties
    // Делегат для обработки событий авторизации
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Private Properties
    // Наблюдатель за прогрессом загрузки с использованием нового KVO API
    private var progressObservation: NSKeyValueObservation?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем WebView
        webView.navigationDelegate = self  // Устанавливаем себя делегатом навигации
        updateProgress()                   // Инициализируем прогресс-бар
        loadAuthView()                     // Загружаем страницу авторизации
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Добавляем наблюдатель за изменением прогресса загрузки
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, _ in
            self?.updateProgress()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Удаляем наблюдатель при исчезновении контроллера, чтобы избежать утечек памяти
        progressObservation = nil
    }
    
    // MARK: - Private Methods
    // Загружает страницу авторизации Unsplash с необходимыми параметрами
    private func loadAuthView() {
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
        webView.load(request)
    }
    
    // Обновляет состояние индикатора прогресса загрузки
    // Скрывает прогресс-бар когда загрузка завершена (прогресс ≈ 1.0)
    private func updateProgress() {
        let progress = Float(webView.estimatedProgress)
        progressView.progress = progress
        // Скрываем прогресс-бар при завершении загрузки (с учетом погрешности)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - Extensions

extension WebViewViewController: WKNavigationDelegate {
    
    // Определяет политику обработки навигационных действий
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Пытаемся извлечь код авторизации из URL
        if let code = code(from: navigationAction) {
            // Если код получен, сообщаем делегату и отменяем дальнейшую обработку
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            // Иначе разрешаем стандартную обработку URL
            decisionHandler(.allow)
        }
    }
    
    // Извлекает код авторизации из URL навигационного действия
    private func code(from navigationAction: WKNavigationAction) -> String? {
        // Проверяем все необходимые условия для извлечения кода:
        guard
            let url = navigationAction.request.url, // URL должен существовать
            let urlComponents = URLComponents(string: url.absoluteString), // Должны быть компоненты URL
            urlComponents.path == "/oauth/authorize/native", // Путь должен соответствовать OAuth callback
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" }) // Должен присутствовать query-параметр "code"
        else {
            return nil
        }
        
        return codeItem.value
    }
}
