//
//  FirebaseManager_Tests.swift
//  SwiftUIFirebaseChatTests
//
//  Created by yu fai on 7/2/2023.
//

import XCTest
import Combine
@testable import SwiftUIFirebaseChat

@available(iOS 16.0, *)
final class FirebaseManager_Tests: XCTestCase {
    private var cancellable = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellable.removeAll()
        
    }

    func test_FirebaseManager_LoginCombine_Failed_badEmail() throws {
        // Given
        let test_email = "testuser@examplecom"
        let test_pw = "testing"
        

        // When
        let mockFirebaseManager = MockFirebaseManager()
        mockFirebaseManager.creatingNewAccount_combine(email: test_email, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertNotNil(error.localizedDescription.ranges(of: "The email address is badly formatted."))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)
    }
    
    func test_FirebaseManager_LoginCombine_Failed_duplicate() throws {
        // Given
        let test_email = "testuser@example.com"
        let test_pw = "testing"
        

        // When
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.creatingNewAccount_combine(email: test_email, password: test_pw)
        mockFirebaseManager.creatingNewAccount_combine(email: test_email, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertNotNil(error.localizedDescription.ranges(of: "Failed to create user The email address is already in use by another account."))
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
