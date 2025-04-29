//
//  Profile.swift
//  ImageFeed
//
//  Сктруктура данных профиля

struct Profile {
    let username: String?
    let name: String?
    let loginName: String?
    let bio: String?
    
    init(ProfileResult: ProfileResult) {
        self.username = ProfileResult.userName
        self.name = ProfileResult.firstName + "" + ProfileResult.lastName
        self.loginName = "@" + ProfileResult.userName
        self.bio = ProfileResult.bio
    }
}
