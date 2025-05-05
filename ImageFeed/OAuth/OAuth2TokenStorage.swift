//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Хранилище токена

import Foundation
import SwiftKeychainWrapper

// Используем UserDefaults в качестве хранилища
final class OAuth2TokenStorage {
    
    private let keychainWrapper = KeychainWrapper.standard
    
    // MARK: Token Property
    private(set) var token: String? {
        get {
            // Получаем токен из стандартного хранилища UserDefaults
            let token = keychainWrapper.string(forKey: "accessToken")
            print("[TokenStorage] Retrieved token: \(token ?? "nil")")
            return token
            
        }
        set {
            guard let newValue else { return }
            // Сохраняем новое значение токена в UserDefaults
            // Если newValue = nil, запись автоматически удаляется
            keychainWrapper.set(newValue, forKey: "accessToken")
            print("[TokenStorage] Saved token: \(newValue)")
        }
    }
    
    // MARK: Public Methods
    
    // Сохраняет новый токен в хранилище.
    
    func storeToken(_ newToken: String) {
        self.token = newToken
    }
    
    // Удаляет текущий токен из хранилища.
    func clearToken() {
        self.token = nil
    }
}
