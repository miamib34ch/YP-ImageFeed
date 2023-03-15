//
//  AlertPresenterDelegate.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject { //без типа AnyObject weak не работает при создании объекта
    func showError()
}
