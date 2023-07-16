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
    let test_email = "testuser@example.com"
    let test_pw = "testing"

    override func setUpWithError() throws {
        
        
    }

    override func tearDownWithError() throws {
        
        cancellable.removeAll()
        
    }

    func test_FirebaseManager_creatingNewAccount_combine_Failed_badEmail() throws {
        // Given
        let badEmail = "testuser@examplecom"
        let test_pw = "testing"
        
        let mockFirebaseManager = MockFirebaseManager()

        // When
        mockFirebaseManager.createNewAccount(email: badEmail, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("The email address is badly formatted."))
                    
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)
    }
    
    func test_FirebaseManager_creatingNewAccount_combine_Failed_duplicate() throws {
        // Given
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)

        // When
        mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("Failed to create user The email address is already in use by another account."))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)
    }
    
    func test_FirebaseManager_creatingNewAccount_combine_Success() throws {
        // Given
        let mockFirebaseManager = MockFirebaseManager()
        
        // When
        mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
            .sink { completion in
                switch completion {
                case .failure(_): break
                default: break
                }
            } receiveValue: { result in
                // Then
                XCTAssertTrue(result)
            }
            .store(in: &cancellable)
    }
    

    func test_FirebaseManager_login_combine_Failed_incorrect_email() throws {
        // Given
        let incorrent_email = "incorrent_email@example.com"
        
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        
        // When
        
        mockFirebaseManager.login(email: incorrent_email, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("Failed to login user There is no user record corresponding to this ifentifier. The user may have been deleted"))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)

        
    }
    
    func test_FirebaseManager_login_combine_Failed_incorrect_password() throws {
        /// Given
        let test_email = "testuser@example.com"
        let incorrent_pw = "incorrent"
        
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        
        // When
        mockFirebaseManager.login(email: test_email, password: incorrent_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("Failed to login user The password is invalid or the user does not have a password"))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)

        
    }
    
    func test_FirebaseManager_login_combine_Failed_empty_email_or_password() throws {
        /// Given
        let empty_email = ""
        let empty_pw = ""
        
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        
        // When
        
        mockFirebaseManager.login(email: test_email, password: empty_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("Please enter an email and password."))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)
        
        mockFirebaseManager.login(email: empty_email, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("Please enter an email and password."))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)

        
    }
    
    func test_FirebaseManager_login_combine_Failed_network_error() throws {
        // Given
        let network_error = "networkerror@example.com"
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        
        // When
        
        mockFirebaseManager.login(email: network_error, password: test_pw)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    // Then
                    XCTAssertTrue(error.localizedDescription.contains("The Internet connection appears to be offline."))
                default: break
                }
            } receiveValue: { _ in
            }
            .store(in: &cancellable)

        
        // Then
    }
    
    func test_FirebaseManager_login_combine_Success() throws {
        // Given
        
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        // When
        mockFirebaseManager.login(email: test_email, password: test_pw)
            .sink { completion in
                switch completion {
                case .failure(_): XCTFail("Logic error")
                default: break
                }
            } receiveValue: { result in
                // Then
                XCTAssertTrue(result)
            }
            .store(in: &cancellable)
        
        // Then
    }

}
