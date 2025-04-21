//
//  Constants.swift
//  ImageFeed
//
//  Константы приложения

import Foundation

enum Constants {
    static let accessKey: String = "RYDyjUfjvCaitGIKzQckqTyHtbQstQraAfl0WE0nTF8"
    static let secretKey: String = "-eN7f8mEWdpjsUedu-_kmSxzxGw-DN3W6NUaBSagTSE"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let defaultBaseURL: URL? = URL(string: "https://api.unsplash.com")
}
