//
//  MockFirebaseManager.swift
//  SwiftUIFirebaseChatTests
//
//  Created by yu fai on 3/3/2023.
//

import Foundation
import Combine
import Firebase

@testable import SwiftUIFirebaseChat

class MockFirebaseManager: NSObject, FirebaseServices {
    let mockFirebaseAuth = MockFirebaseAuth()
    
    func creatingNewAccount_combine(email: String, password: String) -> Future<Bool, Error> {
        Future { promise in
            self.mockFirebaseAuth.createUser(withEmail: email, password: password) { dataResult in
                switch dataResult {
                case .success(_, _):
                    promise(.success(true))
                case .failure(_, let error):
                    promise(.failure(error!))
                case .unknown(_, let error):
                    promise(.failure(error!))
                }
            }
        }
    }
    
    func login_combine(email: String, password: String) -> Future<Bool, Error> {
        Future { promise in
            self.mockFirebaseAuth.signIn(withEmail: email, password: password) { dataResult in
                switch dataResult {
                case .success(_, _):
                    promise(.success(true))
                case .failure(_, let error):
                    promise(.failure(error!))
                case .unknown(_, let error):
                    promise(.failure(error!))
                }
            }
        }
    }
    
}

