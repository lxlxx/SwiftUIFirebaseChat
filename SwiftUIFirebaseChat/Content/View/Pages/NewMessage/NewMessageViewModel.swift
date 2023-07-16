//
//  NewMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI
import Combine

class NewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    
    @Published var errorMsg = ""
    
    var cancellables = Set<AnyCancellable>()
    
    private let firebaseServices: FirebaseServices
    
    init(firebaseServices: FirebaseServices = FirebaseManagerDI()) {
        self.firebaseServices = firebaseServices
        fetchAllUsers()
    }
    
    deinit {
        printLog(GlobalString.deinitText)
    }
    
    private func fetchAllUsers() {
        
        firebaseServices.fetchAllUsers().sink { [weak self] completion in
            switch completion {
            case let .failure(error):
                self?.errorMsg = String(describing: error)
            default: break
            }
        } receiveValue: { [weak self] user in
            self?.users.append(user)
        }.store(in: &cancellables)

        
    }
}
