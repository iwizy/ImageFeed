//
//  URLRequest+Extensions.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 19.04.2025.
//

import Foundation

extension URLRequest {
    // Создает и возвращает настроенный URLRequest для HTTP-запросов
    static func makeHTTPRequest(
        path: String,
        httpMethod: String?,
        baseURL: URL? = Constants.defaultBaseURL
    ) -> URLRequest {
        // Создаем URL из пути и базового URL
        // Используем relativeTo для корректного объединения URL компонентов
        guard let url = URL(string: path, relativeTo: baseURL) else {
            // В случае ошибки прекращаем выполнение с информативным сообщением
            preconditionFailure(
                "[URLRequest] Не удалось создать URL из компонентов: " +
                "baseURL: \(String(describing: baseURL)), " +
                "path: \(path)"
            )
        }
        
        // Создаем базовый запрос
        var request = URLRequest(url: url)
        
        // Устанавливаем HTTP метод если он был передан
        request.httpMethod = httpMethod
        
        return request
    }
}
