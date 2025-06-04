//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Наблюдатель ProfilePresenter

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?

    private(set) var didCallExitProfile = false

    var profileName: String? = "Иванов Иван"
    var profileLoginName: String? = "@ivanovivan"
    var profileBio: String? = "Меня зовут Ваня и я разработчик"
    var avatarURL: URL? = URL(string: "https://example.com/avatar.jpg")

    func viewDidLoad() { }

    func exitProfile() {
        didCallExitProfile = true
    }
}
