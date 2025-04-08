//
//  ProfileViewController.swift
//  ImageFeed
//
//  Класс вью контроллера профиля

import UIKit

final class ProfileViewController: UIViewController {
    
    // Делаем опциональную переменную для вью
    var profileImageView: UIImageView?
    
    // Функция установки аватарки профиля
    private func profileImageSetup() {
        // Создание и установка аватарки на вьюху
        let profileImage = UIImage(named: "profile_photo")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        // Размер и округление
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.layer.cornerRadius = 35
        profileImageView.layer.masksToBounds = true
        
        // Констрейнты
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        self.profileImageView = profileImageView
        
    }
    
    // Функция кнопки выхода
    private func logoutButtonSetup() {
        // Создание и установка кнопки на вьюху
        let logoutImage = UIImage(named: "logout_button")
        guard let logoutImage else { return } // Распаковка картинки, так как они опциональны
        let logoutButton = UIButton.systemButton(with: logoutImage, target: self, action: nil)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        // Размеры и констрейнты
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        guard let profileImageView else { return } // Распаковка картинки, иначе ошибка
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        logoutButton.tintColor = UIColor(named: "YP Red")
        
    }
    
    // Функция размещения лейблов
    private func labelsSetup() {
        // Создание и установка лейбла имени на вьюху
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        // Заполняем лейбл значением и устанавливаем его параметры
        nameLabel.text = "Александр Агафонов"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont(name: "SF Pro", size: 23)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23) // болдим шрифт
        
        // Констрейнты
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        guard let profileImageView else { return } // Распаковка картинки, иначе ошибка
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
    
        
        // Создание и установка лейбла логина на вьюху
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        // Заполняем лейбл значением и устанавливаем его параметры
        loginNameLabel.text = "@iWizard"
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont(name: "SF Pro", size: 13)
        loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        // Констрейнты
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        // Заполняем лейбл значением и устанавливаем его параметры
        descriptionLabel.text = "Hello, reviewer!"
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont(name: "SF Pro", size: 13)
        
        // Констрейнты
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
    }
    
    override func viewDidLoad() {
        profileImageSetup()
        logoutButtonSetup()
        labelsSetup()
    }
}
