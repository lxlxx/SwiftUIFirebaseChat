//
//  MockFirebaseAuth.swift
//  SwiftUIFirebaseChatTests
//
//  Created by yu fai on 5/3/2023.
//

import Foundation
import Firebase
import Combine
@testable import SwiftUIFirebaseChat


enum DataResult: RawRepresentable {
    // MARK: - Data
    case success(String?, Error?)
    case failure(String?, Error?)
    case unknown(String?, Error?)
    
    var rawValue: String {
        switch self {
        case .success(let result, _):
            return result!
        case .failure(_, _):
            return "failure"
        case .unknown(_, _):
            return "unknown"
        }
    }
    
    // MARK: - Life Cycle
    init?(rawValue: String) {
        switch rawValue {
        case "success":
            self = .success(nil, nil)
        case "failure":
            self = .failure(nil, nil)
        default:
            self = .unknown(nil, nil)
        }
    }
    
    init(_ value: (String?, Error?), status: Int) {
        switch status {
        case 200..<300:
            self = .success(value.0, value.1)
        case 400..<500:
            self = .failure(value.0, value.1)
        default:
            self = .unknown(value.0, value.1)
        }
    }
    
    
}


class MockFirebaseAuth {
    // MARK: - Data
    
    // users[email] = password
    var users: [String: String] = [:]
    var isNetworkEnabled = true
    
    
    // MARK: - Func
    
    func persistImageToStorage(imageData: Data) -> Future<DataResult, Error> {
        return Future<DataResult, Error> { promise in
            guard self.users.first != nil else {
                promise(.failure("uid not found"))
                return
            }

            promise(.success(DataResult((SwiftUIFirebaseChat.GlobalString.dummyAvatar, nil), status: 200)))
        }
    }
    
    func createUser(withEmail email: String, password: String, completion: @escaping (DataResult) -> Void?) {
        if email == "testuser@examplecom" {
            let error = NSError(domain: "", code: AuthErrorCode.invalidEmail.rawValue, userInfo: [NSLocalizedDescriptionKey: "The email address is badly formatted."])
            completion(DataResult((nil, error), status: 400))
            return
        }
        
        if (users[email] != nil) {
            let error = NSError(domain: "", code: AuthErrorCode.invalidEmail.rawValue, userInfo: [NSLocalizedDescriptionKey: "Failed to create user The email address is already in use by another account."])
            completion(DataResult((nil, error), status: 400))
            return
            
        }
        
        
        // All other cases return success
        users[email] = password
        completion(DataResult(("success", nil), status: 200))
        
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (DataResult) -> Void?)
    {
        // Test case for network error
        if email == "networkerror@example.com" {
            let error = NSError(domain: "", code: -1009, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."])
            completion(DataResult((nil, error), status: 400))
            return
        }
        
        // Test case for empty email or password
        if email.isEmpty || password.isEmpty {
            let error = NSError(domain: "", code: 17011, userInfo: [NSLocalizedDescriptionKey: "Please enter an email and password."])
            completion(DataResult((nil, error), status: 400))
            return
        }
        
        // Test case for incorrect email
        if (users[email] == nil) {
            let error = NSError(domain: "", code: 17008, userInfo: [NSLocalizedDescriptionKey: "Failed to login user There is no user record corresponding to this ifentifier. The user may have been deleted"])
            completion(DataResult((nil, error), status: 400))
            return
        }
        
        // Test case for incorrect password
        if password != users[email] {
            let error = NSError(domain: "", code: 17009, userInfo: [NSLocalizedDescriptionKey: "Failed to login user The password is invalid or the user does not have a password"])
            completion(DataResult((nil, error), status: 400))
            return
        }
        
        
        // All other cases return success
        completion(DataResult(("success", nil), status: 200))
    }
    
    // Implement other methods of the FirebaseAuth protocol as needed
}
