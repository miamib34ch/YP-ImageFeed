//
//  AuthViewControllerDelegate.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(vc: AuthViewController, didAuthenticateWithCode code: String)
}
