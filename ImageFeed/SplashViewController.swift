//
//  SplashViewController.swift
//  ImageFeed
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    
    // MARK: Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAuthenticated() {
            loadProfileData()
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Private Methods
    
    private func isAuthenticated() -> Bool {
        guard let token = tokenStorage.token else {
            return false
        }
        return !token.isEmpty
    }
    
    private func navigateToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid configuration: window not found")
        }
        
        let tabBarView = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarView
    }
    
    private func loadProfileData() {
        guard isAuthenticated(), let token = tokenStorage.token else {
            print("Ошибка: токен не найден или пуст")
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
            return
        }
        
        if let profile = profileService.profile {
            // Если профиль уже загружен, сразу переходим
            self.navigateToTabBarController()
            print("Профиль уже загружен")
            
            // Безопасное извлечение username
            if let username = profile.username {
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
            }
        } else {
            // Если нет - загружаем
            profileService.fetchProfile(token) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        guard let profile = self?.profileService.profile,
                              let username = profile.username else {
                            print("Профиль или username не загружены")
                            self?.performSegue(withIdentifier: self?.showAuthViewSegueIdentifier ?? "", sender: nil)
                            return
                        }
                        
                        self?.navigateToTabBarController()
                        print("Профиль успешно загружен")
                        ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                        
                    case .failure(let error):
                        print("Ошибка загрузки профиля: \(error.localizedDescription)")
                        self?.performSegue(withIdentifier: self?.showAuthViewSegueIdentifier ?? "", sender: nil)
                    }
                }
            }
        }
    }
}

// MARK: Navigation

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewSegueIdentifier {
            guard let authViewController = segue.destination as? AuthViewController else {
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
    func authViewController(_ vc: AuthViewController, didAuthenticateWith code: String) {
        dismiss(animated: true) {
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success:
                    guard let token = self.tokenStorage.token else {
                        print("Токен не сохранился")
                        return
                    }
                    
                    self.profileService.fetchProfile(token) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                // Проверку на наличие username
                                guard let profile = self.profileService.profile,
                                      let username = profile.username else {
                                    print("Профиль или username не загружены")
                                    return
                                }
                                
                                self.navigateToTabBarController()
                                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                                
                            case .failure(let error):
                                print("Ошибка загрузки профиля: \(error.localizedDescription)")
                            }
                        }
                    }
                case .failure(let error):
                    print("[OAuthViewController] Ошибка получения OAuth токена: \(error.localizedDescription)")
                }
            }
        }
    }
}
