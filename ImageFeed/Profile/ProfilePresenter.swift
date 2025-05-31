//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Презентер профиля

import UIKit


public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    
    
    func exitProfile()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: (any ProfileViewControllerProtocol)?
    
    private let profileLogoutService = ProfileLogoutService.shared
    

    
    func exitProfile() {
        profileLogoutService.logout()
        switchToSplash()
    }
    
    
    
    func switchToSplash() {
        print("[ProfileViewController] ➡️ Go to Splash Screen")
        guard let window = UIApplication.shared.keyWindow else { return }
        window.rootViewController = SplashViewController()
    }
    
}
