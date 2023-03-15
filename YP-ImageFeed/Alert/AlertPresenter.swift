//
//  AlertPresenter.swift
//  YP-ImageFeed
//
//  Created by Богдан Полыгалов on 15.03.2023.
//

import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController?) {
        self.delegate = delegate
    }
    
    func showOneButton(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonOneText, style: .default) { _ in
            model.completionOne()
        }
        
        alert.addAction(action)
        
        guard let delegate = delegate else { return }
        
        delegate.present(alert, animated: true, completion: nil)
    }
    
    func showTwoButton(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonOneText, style: .default) { _ in
            model.completionOne()
        }
        
        let actionTwo = UIAlertAction(title: model.buttonTwoText, style: .default) { _ in
            model.completionTwo()
        }
        
        alert.addAction(action)
        alert.addAction(actionTwo)
        
        guard let delegate = delegate else { return }
        
        delegate.present(alert, animated: true, completion: nil)
    }
}
