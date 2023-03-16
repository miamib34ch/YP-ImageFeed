//
//  YP_ImageFeedUITests.swift
//  YP-ImageFeedUITests
//
//  Created by Богдан Полыгалов on 16.03.2023.
//

import XCTest

final class YP_ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // Переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // Настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // Запускаем приложение перед каждым тестом
    }
    
    func testAuth() throws {
        // Тестируем сценарий авторизации
        
        // Нажать кнопку авторизации
        app.buttons["Authenticate"].tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("email")
        loginTextField.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("password")
        passwordTextField.swipeUp()
        
        // Нажать кнопку логина
        webView.buttons["Login"].tap()
        
        // Тут может возникнуть ошибка, если человек впервые входит. У него появится после логина дополнительное окно, в котором нужно нажать кнопку продолжить (Continue as ИмяПользователя)
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // Тестируем сценарий работы с лентой
        
        // Подождать, пока открывается и загружается экран ленты
        let tablesQuery = app.tables
        
        // Сделать жест «смахивания» вверх для скролла
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        sleep(2)
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["NoActive"].tap()
        sleep(2)
        
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["Active"].tap()
        sleep(2)
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        
        // Подождать, пока картинка открывается на весь экран
        sleep(2)
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // Тестируем сценарий работы с профилем
        
        // Подождать, пока открывается и загружается экран ленты
        sleep(3)
        
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        // Нажать кнопку логаута
        app.buttons["logout button"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        // Проверить, что вернулись в окно авторизации
        XCTAssertTrue(app.buttons["Authenticate"].waitForExistence(timeout: 5))
    }
}
