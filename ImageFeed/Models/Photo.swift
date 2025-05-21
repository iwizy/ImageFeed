//
//  Photo.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 15.05.2025.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}
