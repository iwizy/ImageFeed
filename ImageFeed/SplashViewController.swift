//
//  SplashViewController.swift
//  ImageFeed
//
//  Класс контроллера сплэша


import UIKit

// Контроллер для экрана загрузки (Splash Screen)
final class SplashViewController: UIViewController {
    // Идентификатор перехода к экрану авторизации
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    
    // Сервис профиля
    private let profileService = ProfileService.shared
    
    // Сервис для работы с OAuth2 и хранилище токенов
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    
    
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Проверяем наличие токена для определения следующего экрана
        if let token = tokenStorage.token, !token.isEmpty {
                    loadProfileData()
                } else {
                    performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем стиль status bar при появлении view
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // Устанавливаем светлый стиль для status bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Private Methods
    
    /// Переход к главному экрану с таб-баром
    private func navigateToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid configuration: window not found")
        }
        
        let tabBarView = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarView
    }
}

// MARK: Navigation

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewSegueIdentifier {
            // Настраиваем AuthViewController перед переходом
            guard let authViewController = segue.destination as? AuthViewController else {
                // Логируем ошибку и безопасно обрабатываем ситуацию
                print("Не найден целевой вью контроллер")
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    // Обработка успешной аутентификации
    func authViewController(_ vc: AuthViewController, didAuthenticateWith code: String) {
        // Закрываем экран авторизации и запрашиваем токен
        dismiss(animated: true) {
            self.fetchOAuthToken(code)
        }
    }
    
    
    
    
    private func loadProfileData() {
        profileService.getProfile { [weak self] result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(_):
                    self?.navigateToTabBarController()
                    print("Профиль успешно загружен из сплэш скрина")
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error.localizedDescription)")
                    
                }
            }
        }
    }
    
    
    // Запрос OAuth токена по коду авторизации
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loadProfileData()
                    //self.navigateToTabBarController()
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print("[OAuthViewController] Ошибка получения OAuth токена: \(error.localizedDescription)")
                    break
                }
            }
        }
    }
}
