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
    let firstButtonText: String
    let firstButtonCompletion: (() -> Void)?
    let secondButtonText: String?
    let secondButtonCompletion: (() -> Void)?
}
