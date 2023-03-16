//
//  ProfileTest.swift
//  YP-ImageFeedTests
//
//  Created by Богдан Полыгалов on 16.03.2023.
//

@testable import YP_ImageFeed
import XCTest

final class ProfileTest: XCTestCase {
    func testPresenterCreateImage() {
        //given
        let presenter = ProfileViewPresenter()
        
        //when
        let image = presenter.createImage()
        
        //then
        XCTAssertEqual(image.image, UIImage(named: "Placeholder"))
    }
    
    func testPresenterCreateLabel() {
        //given
        let presenter = ProfileViewPresenter()
        
        //when
        let label = presenter.createLabel(text: "test", color: .black, font: UIFont())
        
        //then
        XCTAssertEqual(label.text, "test")
    }
    
    func testPresenterCreateButtonReturnVoidButton() {
        //given
        let presenter = ProfileViewPresenter()
        
        //when
        let button = presenter.createButton()
        
        //then
        XCTAssertEqual(button.currentImage, UIButton().currentImage)
    }
    
    func testPresenterCreateButton() {
        //given
        let presenter = ProfileViewPresenter()
        presenter.view = ProfileViewController()
        
        //when
        let button = presenter.createButton()
        
        //then
        XCTAssertEqual(button.currentImage, UIImage(named: "Exit"))
    }
    
    func testPresenterCreateAlertModel() {
        //given
        let presenter = ProfileViewPresenter()
        
        //when
        let alert = presenter.createAlertModel()
        
        //then
        XCTAssertEqual(alert.title, "Пока, пока!")
    }
    
    func testControllerViewDidLoad() {
        //given
        let controller = ProfileViewController()
        
        //when
        let _ = controller.view
        
        //then
        XCTAssertNotNil(controller.presenter)
    }
}
