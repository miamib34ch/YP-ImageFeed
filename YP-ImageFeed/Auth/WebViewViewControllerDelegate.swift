//
//  WebViewViewControllerDelegate.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
