//
//  ProfileViewController.swift
//  ImageFeed
//
//  Класс вью контроллера профиля

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: Properties
    // Опциональное свойство для хранения изображения профиля
    // Используется weak var, так как UIImageView уже хранится в view hierarchy
    private var profileImageView: UIImageView?
    
    // MARK: Private Methods
    
    // Настройка аватарки профиля
    private func profileImageSetup() {
        let profileImage = UIImage(named: "profile_photo")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        // Констрейнты
        profileImageView.layer.cornerRadius = 35
        profileImageView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        // Сохраняем ссылку на imageView в свойство класса
        self.profileImageView = profileImageView
    }
    
    // Настройка кнопки выхода
    private func logoutButtonSetup() {
        let logoutImage = UIImage(named: "logout_button")
        guard let logoutImage else { return } // Безопасная распаковка опционального изображения
        let logoutButton = UIButton.systemButton(with: logoutImage, target: self, action: nil)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        guard let profileImageView else { return } // Проверяем, что profileImageView был создан
        // Установка размеров кнопки
        NSLayoutConstraint.activate([
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
        logoutButton.tintColor = UIColor(named: "YP Red")
    }
    
    // Настройка текстовых лейблов (имя, логин, описание)
    private func labelsSetup() {
        // MARK: Name Label
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        // Установка текста, цвета и шрифта для имени
        nameLabel.text = "Александр Агафонов"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        guard let profileImageView else { return }
        
        // MARK: Login Label
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        // Установка текста, цвета и шрифта для логина
        loginNameLabel.text = "@iWizard"
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        // MARK: Description Label
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // Установка текста, цвета и шрифта для описания
        descriptionLabel.text = "Hello, reviewer!"
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        // Констрейнты
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8)
        ])
        
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Вызов методов настройки UI при загрузке view
        profileImageSetup()
        logoutButtonSetup()
        labelsSetup()
    }
}
