//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Хранилище токена

import Foundation
import SwiftKeychainWrapper

// Используем UserDefaults в качестве хранилища
final class OAuth2TokenStorage {
    // MARK: - Private Properties
    private let keychainWrapper = KeychainWrapper.standard
    private let userDefaults = UserDefaults.standard
    private let isFirstLaunchKey = "isFirstLaunch"

    // MARK: - Initializers
    init() {
        checkFirstLaunch()
    }

    // MARK: - Public Methods
    // Сохраняет новый токен в хранилище.
    func storeToken(_ newToken: String) {
        self.token = newToken
    }
    
    // Удаляет текущий токен из хранилища.
    func clearToken() {
        self.token = nil
    }

    // MARK: - Private Methods
    private func checkFirstLaunch() {
        if !userDefaults.bool(forKey: isFirstLaunchKey) {
            // Первый запуск после установки
            clearToken()
            userDefaults.set(true, forKey: isFirstLaunchKey)
            print("[TokenStorage] First launch detected, keychain cleared")
        }
    }
    
    private(set) var token: String? {
        get {
            // Получаем токен из стандартного хранилища UserDefaults
            let token = keychainWrapper.string(forKey: "accessToken")
            print("[TokenStorage] Retrieved token: \(token ?? "nil")")
            return token
            
        }
        set {
            if let newValue = newValue {
                keychainWrapper.set(newValue, forKey: "accessToken")
                print("[TokenStorage] Saved token: \(newValue)")
            } else {
                keychainWrapper.removeObject(forKey: "accessToken")
                print("[TokenStorage] Token removed")
            }
        }
    }
}
