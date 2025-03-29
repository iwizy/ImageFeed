//
//  ProfileViewController.swift
//  ImageFeed
//
//  Класс вью контролдлера профиля

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    
    @IBOutlet weak var avatarClicked: UIImageView!
    @IBOutlet weak var logoutButtonClicked: UIButton!
}

