//
//  AuthViewController.swift
//  ImageFeed
//
//  Класс вью контроллера авторизации

import UIKit

final class AuthViewController: UIViewController {
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black") // 4
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButton()
    }
}
