//
//  WebViewViewController.swift
//  ImageFeed
//
//  Класс webview контроллера

import UIKit
import WebKit

// Контроллер для отображения веб-интерфейса авторизации через OAuth 2.0
final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    
    // MARK: Outlets
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Public Properties
    // Делегат для обработки событий авторизации
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    // MARK: - Private Properties
    // Наблюдатель за прогрессом загрузки с использованием нового KVO API
    private var progressObservation: NSKeyValueObservation?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Настраиваем WebView
        webView.navigationDelegate = self  // Устанавливаем себя делегатом навигации
        presenter?.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Добавляем наблюдатель за изменением прогресса загрузки
        progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [self] _,_ in
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Удаляем наблюдатель при исчезновении контроллера, чтобы избежать утечек памяти
        progressObservation = nil
    }
    
    // MARK: - Public Methods
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    
}

// MARK: - Extensions

extension WebViewViewController: WKNavigationDelegate {
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
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
