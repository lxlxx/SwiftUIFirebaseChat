//
//  LoginAndRegistration_ViewModel_Tests.swift
//  SwiftUIFirebaseChatTests
//
//  Created by yu fai on 8/3/2023.
//

import XCTest
import Combine
@testable import SwiftUIFirebaseChat

final class LoginAndRegistration_ViewModel_Tests: XCTestCase {
    let mockFirebaseManager = MockFirebaseManager()
    private var cancellable = Set<AnyCancellable>()
    let test_email = "testuser@example.com"
    let test_pw = "testing"
    
    override func setUpWithError() throws {
        
        
    }

    override func tearDownWithError() throws {
        
        cancellable.removeAll()
    }

    func test_LoginAndRegistrationView_ViewModel_login_Failed_incorrect_email() throws {
        // Given
        let vm = LoginAndRegistrationViewModel(firebaseServices: mockFirebaseManager)
        let incorrent_email = "incorrent_email@example.com"
        
        // When
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        vm.email = incorrent_email
        vm.password = test_pw
        vm.login()
        
        // Then
        XCTAssertEqual(vm.progressViewEnabled, false)
        XCTAssertEqual(vm.statusMessage, "Failed to login user There is no user record corresponding to this ifentifier. The user may have been deleted")
        
    }
    
    func test_LoginAndRegistrationView_ViewModel_login_Failed_incorrect_password() throws {
        // Given
        let vm = LoginAndRegistrationViewModel(firebaseServices: mockFirebaseManager)
        let incorrent_pw = "incorrent"
        
        // When
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        vm.email = test_email
        vm.password = incorrent_pw
        vm.login()
        
        // Then
        XCTAssertEqual(vm.progressViewEnabled, false)
        XCTAssertEqual(vm.statusMessage, "Failed to login user The password is invalid or the user does not have a password")
        
    }
    
    func test_LoginAndRegistrationView_ViewModel_login_Failed_empty_email_or_password() throws {
        // Given
        let vm = LoginAndRegistrationViewModel(firebaseServices: mockFirebaseManager)
        let empty_email = ""
        let empty_pw = ""
        
        // When
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        vm.email = test_email
        vm.password = empty_pw
        vm.login()
        
        // Then
        XCTAssertEqual(vm.progressViewEnabled, false)
        XCTAssertEqual(vm.statusMessage, "Please enter an email and password.")
        
        // When
        vm.email = empty_email
        vm.password = test_pw
        vm.login()
        
        // Then
        XCTAssertEqual(vm.progressViewEnabled, false)
        XCTAssertEqual(vm.statusMessage, "Please enter an email and password.")
    }
    
    func test_LoginAndRegistrationView_ViewModel_login_Failed_network_error() throws {
        // Given
        let vm = LoginAndRegistrationViewModel(firebaseServices: mockFirebaseManager)
        let network_error = "networkerror@example.com"
        
        // When
        let _ = mockFirebaseManager.createNewAccount(email: test_email, password: test_pw)
        vm.email = network_error
        vm.password = test_pw
        vm.login()
        
        // Then
        XCTAssertEqual(vm.progressViewEnabled, false)
        XCTAssertEqual(vm.statusMessage, "The Internet connection appears to be offline.")
    }
    
    func test_LoginAndRegistrationView_ViewModel_login_Success() throws {
        // Given
        let vm = LoginAndRegistrationViewModel(firebaseServices: mockFirebaseManager)
        
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
        
        
    }
}
