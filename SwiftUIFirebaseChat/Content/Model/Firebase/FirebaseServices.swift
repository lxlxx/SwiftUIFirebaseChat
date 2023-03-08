//
//  FirebaseServices.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 3/3/2023.
//

import Foundation
import Combine

protocol FirebaseServices {
    
//    static var shared: FirebaseServices { get }
    
    func login_combine(email: String, password: String) -> Future<Bool, Error>
    
    func creatingNewAccount_combine(email: String, password: String) -> Future<Bool, Error>
}
