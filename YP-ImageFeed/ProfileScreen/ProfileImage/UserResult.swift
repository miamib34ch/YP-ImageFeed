//
//  UserResult.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 08.03.2023.
//

import Foundation

struct UserResult: Codable {
    let profile_image: ProfileImage // Ответ сервера возвращает не массив, а объект
}

struct ProfileImage: Codable { // Поля объекта
    let small: String
    let medium: String
    let large: String
}
