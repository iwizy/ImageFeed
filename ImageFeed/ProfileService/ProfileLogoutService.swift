//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Сервис разлогина пользователя и очистки данных

import Foundation
import WebKit
import Kingfisher

final class ProfileLogoutService {
    // MARK: - Public Properties
    static let shared = ProfileLogoutService()
    
    // MARK: - Private Properties
    private let imagesListService = ImagesListService.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Initializers
    private init() { }
    
    // MARK: - Public Methods
    func logout() {
        clearCookies()
        clearAllData()
    }
    
    // MARK: - Private Methods
    // Удаляем куки
    private func clearCookies() {
        print("[ProfileLogoutService] ➡️ Clear cookies")
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearAllData() {
        // очистка всех изображений
        imagesListService.cleatImagesList()
        // очистка профиля
        profileService.clearProfile()
        // очистка картинки профиля
        profileImageService.clearProfileImage()
        // очистка токена
        oAuth2TokenStorage.clearToken()
        // очистка кеша кингфишера
        print("[ProfileLogoutService] ➡️ Clear Kingfisher cache")
        KingfisherManager.shared.cache.clearCache()
    }
}
