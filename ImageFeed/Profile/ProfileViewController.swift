//
//  ProfileViewController.swift
//  ImageFeed
//
//  Класс вью контроллера профиля

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateAvatar()
    func updateProfileData()
    
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    var presenter: (any ProfilePresenterProtocol)?
    
    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    private var profileResult: ProfileResult? {
        didSet {
            updateProfileData()
        }
    }
    
    private var currentProfile: Profile? {
        guard let profileResult = profileResult else { return nil }
        return Profile(ProfileResult: profileResult)
    }
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // UI Elements
    private let profileImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "profile_image_placeholder"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: "YP Red")
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Имя Фамилия" // Временное значение
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@username" // Временное значение
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Описание профиля" // Временное значение
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    // MARK: - Initializers
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        setupViews()
        setupConstraints()
        updateProfileData()
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Private Methods
    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "profile_image_placeholder"))
        
    }
    
    private func setupViews() {
        view.addSubview(profileImage)
        view.addSubview(logoutButton)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    
    func updateProfileData() {
        guard let profile = profileService.profile else {
            print("Нет данных профиля для отображения")
            return
        }
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    @objc private func didTapLogoutButton() {
        showLogoutAlert()
    }
    
    
    func showLogoutAlert() {
        print("[ProfileViewController] ➡️ User tapped lougout button")
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Нет", style: .default))
        alert.addAction(UIAlertAction(title: "Да", style: .cancel) { [weak self] _ in
            self?.presenter?.exitProfile()
        })
        present(alert, animated: true)
    }
    
    
}
