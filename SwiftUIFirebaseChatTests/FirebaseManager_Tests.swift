//
//  FirebaseManager_Tests.swift
//  SwiftUIFirebaseChatTests
//
//  Created by yu fai on 7/2/2023.
//

import XCTest
import Combine
@testable import SwiftUIFirebaseChat

final class FirebaseManager_Tests: XCTestCase {
    private var cancellable = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellable.removeAll()
    }

    @available(iOS 16.0, *)
    func test_FirebaseManager_LoginCombine_Failed() throws {
        // Given
        let test_email = "testing@gmail.com"
        let test_pw = "testing"
        
        // When
        FirebaseManager.shared.login_combine(email: test_email, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertNotNil(error.localizedDescription.ranges(of: "Failed to login user"))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)
        
        
        

        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
