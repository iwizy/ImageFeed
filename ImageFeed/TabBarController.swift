//
//  TabBarController.swift
//  ImageFeed
//
//  Контроллер таббара

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        // ImagesList setup
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController else {
            assertionFailure("Не удалось привести ImagesListViewController")
            return
        }
        
        let imagesListPresenter = ImagesListPresenter()
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imagesListPresenter
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil
        )
        
        // Profile setup
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
