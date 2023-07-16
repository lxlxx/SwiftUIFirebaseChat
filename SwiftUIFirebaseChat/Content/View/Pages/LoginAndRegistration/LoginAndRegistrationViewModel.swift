//
//  LoginAndRegistrationViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI
import Combine

class LoginAndRegistrationViewModel: ObservableObject {
    
    // MARK: - Data
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var statusMessage = ""
    @Published var passwordStatusMessage = ""
    
    @Published var loggedIn = false
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var validatedPassword = false
    
    @Published var validatedInput = false
    
    @Published var isLoginMode = true
    
    @Published var submitEnabled = false
    
    @Published var progressViewEnabled = false
    
    private var firebaseServices: FirebaseServices
    
    
    // MARK: - Func
    func login() {
        
        firebaseServices.login(email: self.email, password: self.password)
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.statusMessage = String(describing: error.localizedDescription)
                    self?.progressViewEnabled = false
                default: break
                }
            } receiveValue: { [weak self] result in
                self?.loggedIn = result
            }
            .store(in: &cancellables)
        
    }
    
    
    func createNewAccount(image avatarImage: UIImage?) {
        guard let avatarImage = avatarImage else {
                    statusMessage = GlobalString.selectAnAvatar
                    progressViewEnabled = false
                    return
                }
        guard let imageData = avatarImage.jpegData(compressionQuality: 0.2) else { return }
        
        firebaseServices.createNewAccount(email: email, password: password)
            .flatMap { [unowned self] result  in
                self.firebaseServices.persistImageToStorage(imageData: imageData)
            }
            .flatMap { [unowned self] (uid, url) in
                self.firebaseServices.updateUserInformation(email: email,
                                                                       uid: uid,
                                                                       imageProfileUrl: url)
            }
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.statusMessage = String(describing: error)
                    self?.progressViewEnabled = false
                default: break
                }
            } receiveValue: { [weak self] result in
                self?.loggedIn = result
            }
            .store(in: &cancellables)
            
    }
    
    
    init(firebaseServices: FirebaseServices = FirebaseManagerDI()) {
        self.firebaseServices = firebaseServices

        $password
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .combineLatest($confirmPassword, $isLoginMode)
            .sink{ [unowned self] password, confirmPassword, isLoginMode in
                self.validatedPassword = password.count > 0 && password == confirmPassword
                let showPasswordMessage = password.count > 0 && confirmPassword.count > 0 && password != confirmPassword && !isLoginMode
                self.passwordStatusMessage = showPasswordMessage ? GlobalString.passwordNotSame : ""
            }
            .store(in: &cancellables)

        $password
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .combineLatest($email)
            .sink { [unowned self] password, email in
                self.validatedInput = password.count > 0 && email.count > 0
            }
            .store(in: &cancellables)
        
        $isLoginMode
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .combineLatest($validatedPassword, $validatedInput)
            .sink { [unowned self] isLoginMode, validatedPassword, validatedinput in
                if isLoginMode {
                    self.submitEnabled = validatedinput
                } else {
                    self.submitEnabled = validatedinput && validatedPassword
                }
            }
            .store(in: &cancellables)
        
        
    }
    
}
