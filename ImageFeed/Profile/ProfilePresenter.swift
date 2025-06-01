//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Презентер профиля

import UIKit

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    
    var profileName: String? {
        profileService.profile?.name
    }
    
    var profileLoginName: String? {
        profileService.profile?.loginName
    }
    
    var profileBio: String? {
        profileService.profile?.bio
    }
    
    var avatarURL: URL? {
        guard let urlString = profileImageService.avatarURL else { return nil }
        return URL(string: urlString)
    }
    
    // MARK: - Private Properties
    private let profileLogoutService = ProfileLogoutService.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        view?.updateProfileData()
        view?.updateAvatar()
    }
    
    // MARK: - Public Methods
    func exitProfile() {
        profileLogoutService.logout()
        switchToSplash()
    }
    
    // MARK: - Private Methods
    private func switchToSplash() {
        print("[ProfilePresenter] ➡️ Go to Splash Screen")
        guard let window = UIApplication.shared.windows.first else { return }
        window.rootViewController = SplashViewController()
    }
}
