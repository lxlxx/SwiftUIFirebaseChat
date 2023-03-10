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
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        cancellable.removeAll()
    }

    func test_LoginAndRegistration_LBTA_ViewModel_login_Failed_incorrect_email() throws {
        // Given
        let vm = LoginAndRegistration_LBTA_ViewModel(firebaseServices: mockFirebaseManager)
        let incorrent_email = "incorrent_email@example.com"
        
        let _ = mockFirebaseManager.creatingNewAccount_combine(email: test_email, password: test_pw)
        vm.email = incorrent_email
        vm.password = test_pw
        vm.login()
        
        XCTAssertEqual(vm.programViewEnabled, false)
        XCTAssertEqual(vm.statusMessage, "Failed to login user The password is invalid or the user does not have a password")
        
    }
    
    func test_LoginAndRegistration_LBTA_ViewModel_login_Failed_incorrect_password() throws {
        // Given
        
        let test_email = "testuser@example.com"
        let incorrent_pw = "incorrent"
        
        
    }
    
    func test_LoginAndRegistration_LBTA_ViewModel_login_Failed_empty_email_or_password() throws {
        // Given
        let vm = LoginAndRegistration_LBTA_ViewModel(firebaseServices: mockFirebaseManager)
        let empty_email = ""
        let empty_pw = ""
        
        
    }
    
    func test_LoginAndRegistration_LBTA_ViewModel_login_Failed_network_error() throws {
        // Given
        let vm = LoginAndRegistration_LBTA_ViewModel(firebaseServices: mockFirebaseManager)
        let network_error = "networkerror@example.com"
        
        
    }
    
    func test_LoginAndRegistration_LBTA_ViewModel_login_Success() throws {
        // Given
        let vm = LoginAndRegistration_LBTA_ViewModel(firebaseServices: mockFirebaseManager)
        
        let mockFirebaseManager = MockFirebaseManager()
        let _ = mockFirebaseManager.creatingNewAccount_combine(email: test_email, password: test_pw)
        
        // When
        mockFirebaseManager.creatingNewAccount_combine(email: test_email, password: test_pw)
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
        
        // Then
    }
}
