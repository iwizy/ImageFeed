//
//  SplashViewController.swift
//  ImageFeed
//
// Вью контроллер сплэша

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let profileService = ProfileService.shared
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let profileImageService = ProfileImageService.shared
    
    // UI Elements
    private let splashLogo: UIImageView = {
       let logoImageView = UIImageView(image: UIImage(named: "SplashLogo"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        setupViews()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isAuthenticated() {
            loadProfileData()
        } else {
            loadAuthView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Public Methods
    func loadAuthView() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            guard let viewController = viewController as? AuthViewController else { return }
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
    }

    // MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            splashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        ])
    }
    
    private func setupViews() {
        view.addSubview(splashLogo)
    }
    
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
            self.navigateToTabBarController()
            print("Профиль уже загружен")
            
            if let username = profile.username {
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
            }
        } else {
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

// MARK: - Extensions

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

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWith code: String) {
        dismiss(animated: true) {
            self.fetchOAuthToken(code, authViewController: vc)
        }
    }
    
    private func fetchOAuthToken(_ code: String, authViewController: AuthViewController) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                guard let self = self else { return }
                
                switch result {
                case .success:
                    guard let token = self.tokenStorage.token else {
                        authViewController.showErrorAlert()
                        return
                    }
                    
                    self.profileService.fetchProfile(token) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                guard let profile = self.profileService.profile,
                                      let username = profile.username else {
                                    authViewController.showErrorAlert()
                                    return
                                }
                                
                                self.navigateToTabBarController()
                                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                                
                            case .failure:
                                authViewController.showErrorAlert()
                            }
                        }
                    }
                case .failure:
                    authViewController.showErrorAlert()
                }
            }
        }
    }
}
