//
//  UserResult.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 01.05.2025.
//

struct UserResult: Decodable {
    let profileImage: UserImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct UserImage: Decodable {
    let currentUserImage: String?
    
    enum CodingKeys: String, CodingKey {
        case currentUserImage = "small"
    }
}
