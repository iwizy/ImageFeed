//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Наблюдатель ProfileViewController

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?

    private(set) var didCallUpdateProfileData = false
    private(set) var didCallUpdateAvatar = false

    func updateProfileData() {
        didCallUpdateProfileData = true
    }

    func updateAvatar() {
        didCallUpdateAvatar = true
    }
}
