//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Alexander Agafonov on 18.04.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
