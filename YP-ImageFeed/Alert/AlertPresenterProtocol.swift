//
//  AlertPresenterProtocol.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import Foundation

protocol AlertPresenterProtocol {
    func showOneButton(model: AlertModel)
    func showTwoButton(model: AlertModel)
}
