//
//  SwiftUIFirebaseChatUITests.swift
//  SwiftUIFirebaseChatUITests
//
//  Created by yu fai on 27/11/2021.
//
//https://www.hackingwithswift.com/articles/83/how-to-test-your-user-interface-using-xcode

//XCUITest: what is the definitive, locale-agnostic way to dismiss the (software) keyboard?
//https://developer.apple.com/forums/thread/115713

//https://www.appsloveworld.com/swift/100/7/how-to-hide-keyboard-in-swift-app-during-ui-testing

//https://stackoverflow.com/questions/34684846/how-to-detect-if-keyboard-is-shown-in-xcode-ui-test

//Unit Testing UITextField(s). Keyboard Type.
//https://www.youtube.com/watch?v=0TUDDxCNp0A&ab_channel=SergeyKargopolov

import XCTest

class SwiftUIFirebaseChatUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_LoginAndRegistration_loginButton_loginFailed() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        
        let emailTextField = app.textFields["Email"]
        let pwTextField = app.secureTextFields["Password"]
        
        sleep(1)
        emailTextField.tap()
        emailTextField.typeText("testing@gmail.com")
        
        pwTextField.tap()
        pwTextField.typeText("test")

        sleep(2)
        scrollViewsQuery.otherElements.containing(.textField, identifier:"Email").children(matching: .button)["Login"].tap()

        let result = app.staticTexts["Failed to login user There is no user record corresponding to this identifier. The user may have been deleted."]
        sleep(5)
        XCTAssertTrue(result.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
