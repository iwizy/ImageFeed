//
//  ProfileResult.swift
//  ImageFeed
//
//  Структура данных полученного профиля

import Foundation

struct ProfileResult: Decodable {
    let userName: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    private enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}
