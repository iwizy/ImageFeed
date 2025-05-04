//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Хранилище токена

import Foundation

// Используем UserDefaults в качестве хранилища
final class OAuth2TokenStorage {
    
    // MARK: Token Property
    private(set) var token: String? {
        get {
            // Получаем токен из стандартного хранилища UserDefaults
            let token = UserDefaults.standard.string(forKey: "accessToken")
            print("[TokenStorage] Retrieved token: \(token ?? "nil")")
            return token
            
        }
        set {
            // Сохраняем новое значение токена в UserDefaults
            // Если newValue = nil, запись автоматически удаляется
            UserDefaults.standard.set(newValue, forKey: "accessToken")
            print("[TokenStorage] Saved token: \(newValue ?? "nil")")
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
