//
//  Profile.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 05.03.2023.
//

import Foundation

struct Profile {
    
    var username: String?
    var name: String?
    var loginName: String?
    var bio: String?
    
    init(profileResult: ProfileResult) {
        username = profileResult.username
        loginName = "@" + (username ?? "")
        name = (profileResult.first_name ?? "") + " " + (profileResult.last_name ?? "")
        bio = profileResult.bio
    }
}
