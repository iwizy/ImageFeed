//
//  AuthViewController.swift
//  ImageFeed
//
//  Класс вью контроллера авторизации

import UIKit

// Протокол делегата для обработки событий авторизации
protocol AuthViewControllerDelegate: AnyObject {
    // Метод вызывается при успешной аутентификации
    func authViewController(_ vc: AuthViewController, didAuthenticateWith code: String)
}

// Контроллер для экрана авторизации, управляет процессом OAuth аутентификации
final class AuthViewController: UIViewController {
    

    // MARK: Constants
    // Идентификатор перехода к WebView
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // Делегат для обработки событий авторизации
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: UI Configuration
    
    // Настраивает кнопку "Назад" в navigation bar
    private func configureBackButton() {
        // Устанавливаем кастомную иконку для кнопки назад
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        
        // Создаем кастомный UIBarButtonItem для кнопки назад
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        
        // Устанавливаем цвет кнопки "Назад"
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настраиваем UI при загрузке view
        configureBackButton()
        navigationItem.hidesBackButton = true
    }
    
    // MARK: Navigation
    
    // Подготавливает данные перед переходом на другой экран

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверяем идентификатор перехода
        if segue.identifier == showWebViewSegueIdentifier {
            // Безопасно извлекаем WebViewViewController
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Failed to prepare for \(showWebViewSegueIdentifier)")
            }
            
            // Устанавливаем себя делегатом WebViewViewController
            webViewViewController.delegate = self
        } else {
            // Для других segue вызываем стандартную реализацию
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    // Обрабатывает успешную авторизацию через WebView
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        // Передаем событие дальше своему делегату
        delegate?.authViewController(self, didAuthenticateWith: code)
    }
    
    // Обрабатывает отмену авторизации в WebView
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        // Закрываем экран авторизации
        dismiss(animated: true)
    }
}
