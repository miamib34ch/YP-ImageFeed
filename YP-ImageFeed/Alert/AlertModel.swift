//
//  AlertModel.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonOneText: String
    let completionOne: () -> Void
    let buttonTwoText: String
    let completionTwo: () -> Void
}
