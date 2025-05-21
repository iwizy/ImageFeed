//
//  Profile.swift
//  ImageFeed
//
//  Структура данных конечного вида профиля

struct Profile {
    let username: String?
    let name: String?
    let loginName: String?
    let bio: String?
    
    init(ProfileResult: ProfileResult) {
        self.username = ProfileResult.userName
        self.name = [ProfileResult.firstName, ProfileResult.lastName]
            .compactMap { $0 }
            .joined(separator: " ")
        self.loginName = "@" + ProfileResult.userName
        self.bio = ProfileResult.bio
    }
}
