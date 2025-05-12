//
//  UserResult.swift
//  ImageFeed
//
//  Структура данных изображения профиля

struct UserResult: Decodable {
    let profileImage: UserImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct UserImage: Decodable {
    let currentUserImage: String?
    
    enum CodingKeys: String, CodingKey {
        case currentUserImage = "large"
    }
}
