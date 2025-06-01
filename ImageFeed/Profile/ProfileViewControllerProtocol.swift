//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Протокол ProfileViewController


protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }

    func updateAvatar()
    func updateProfileData()
}
