//
//  ProfilePresenterProtocol.swift
//  ImageFeed
//
//  Протокол ProfilePresenter

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profileName: String? { get }
    var profileLoginName: String? { get }
    var profileBio: String? { get }
    var avatarURL: URL? { get }
    
    func viewDidLoad()
    func exitProfile()
}
