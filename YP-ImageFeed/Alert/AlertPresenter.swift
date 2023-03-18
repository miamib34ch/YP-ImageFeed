//
//  AlertPresenter.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject { // Без типа AnyObject weak не работает при создании объекта
    func showAlert()
}

protocol AlertPresenterProtocol {
    func showAlertWithOneButton(model: AlertModel)
    func showAlertWithTwoButton(model: AlertModel)
}

struct AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    func showAlertWithOneButton(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.firstButtonText, style: .default) { _ in
            model.firstButtonCompletion?()
        }
        
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithTwoButton(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let firstAction = UIAlertAction(title: model.firstButtonText, style: .default) { _ in
            model.firstButtonCompletion?()
        }
        
        let secondAction = UIAlertAction(title: model.secondButtonText, style: .default) { _ in
            model.secondButtonCompletion?()
        }
        
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
