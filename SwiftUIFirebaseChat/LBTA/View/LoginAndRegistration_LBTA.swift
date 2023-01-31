//
//  LoginAndRegistration_LBTA.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 13/10/2022.
//

//Introducing Combine
//https://developer.apple.com/videos/play/wwdc2019/722

//Combine in Practice
//https://developer.apple.com/videos/play/wwdc2019/721

import SwiftUI
import Combine

class LoginAndRegistration_LBTA_ViewModel: ObservableObject {
    
    // MARK: - Data
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var statusMessage = ""
    
    @Published var loggedIn = false
    
    private var cancellable = Set<AnyCancellable>()
    
    @Published var validatedPassword = false
    
    @Published var validatedinput = false
    
    @Published var isLoginMode = true
    
    @Published var submitEnabled = false
    
    // MARK: - Func
    func login() {
        FirebaseManager.shared.login_combine(email: self.email, password: self.password)
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.statusMessage = String(describing: error)
                default: break
                }
            } receiveValue: { [weak self] result in
                self?.loggedIn = result
            }.store(in: &cancellable)
        
    }
    
//https://www.donnywals.com/configuring-error-types-when-using-flatmap-in-combine/
//https://stackoverflow.com/questions/57543855/using-just-with-flatmap-produce-failure-mismatch-combine
//https://www.avanderlee.com/swift/combine-error-handling/
    
//https://swiftwithmajid.com/2021/05/12/combining-multiple-combine-publishers-in-swift/
//https://augmentedcode.io/2022/10/03/combine-publishers-merge-zip-and-combinelatest-on-ios/
    
    func creatingNewAccount(image avatarImage: UIImage?) {
        
        if avatarImage == nil {
            self.statusMessage = "You must select an avatar image"
        }
        guard let imageData = avatarImage?.jpegData(compressionQuality: 0.2) else { return }
        FirebaseManager.shared.creatingNewAccount_combine(email: self.email, password: self.password)
            .flatMap { result -> AnyPublisher<(String, URL), Error> in
                FirebaseManager.shared.persistingImageToStorage_combine(imageData: imageData)
                    .eraseToAnyPublisher()
            }
            .flatMap { [unowned self] (uid, url) in
                FirebaseManager.shared.updatingUserInformation_combine(email: self.email,
                                                                       uid: uid,
                                                                       imageProfileUrl: url)
            }
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    self?.statusMessage = String(describing: error)
                default: break
                }
            } receiveValue: { [weak self] result in
                self?.loggedIn = result
            }.store(in: &cancellable)
    }
    
    
    init() {
        $password
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { password in
                print("password \(password)")
            }
            .store(in: &cancellable)
//        $password
//            .combineLatest($confirmPassword)
//            .allSatisfy { password, confirmPassword in
//                print("validatedPassword, \(password), \(confirmPassword)")
//                return password.count > 0 && password == confirmPassword
//            }
//            .sink { [unowned self] result in
//                self.validatedPassword = result
//            }
//            .store(in: &cancellable)
        
        $password
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .combineLatest($confirmPassword)
            .sink{ [unowned self] password, confirmPassword in
                self.validatedPassword = password.count > 0 && password == confirmPassword
            }
            .store(in: &cancellable)

        $password
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .combineLatest($email)
            .sink { [unowned self] password, email in
                self.validatedinput = password.count > 0 && email.count > 0
            }
            .store(in: &cancellable)
        
        $isLoginMode
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .combineLatest($validatedPassword, $validatedinput)
            .sink { [unowned self] isLoginMode, validatedPassword, validatedinput in
                if isLoginMode {
                    self.submitEnabled = validatedinput
                } else {
                    self.submitEnabled = validatedinput && validatedPassword
                }
            }
            .store(in: &cancellable)
    }
    
}

struct LoginAndRegistration_LBTA: View {
    
    // MARK: - Data
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var vm = LoginAndRegistration_LBTA_ViewModel()
    
    @State private var shouldShowImagePicker = false
    
    @State private var avatarImage: UIImage?
    
    @State private var programViewEnabled = false
    
    // MARK: - Func
    
    private func handlingSubmitAction() {
        programViewEnabled = true
        if vm.isLoginMode {
            vm.login()
        } else {
            vm.creatingNewAccount(image: avatarImage)
        }
    }
    
    private func dismissView() {
        programViewEnabled = false
        presentationMode.wrappedValue.dismiss()
    }
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16){
                        
                        loginAndRegistrationPicker
                        
                        imagePickerView
                        
                        userInformationTextFields
                        
                        submitButton
                        
                        loginStatusMessageTextView
                        
                    }
                    .padding()
                }
                programView
                    
            }
            .navigationTitle(vm.isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white:0, alpha: 0.05))
                .ignoresSafeArea())
            
        }
        //        .navigationSplitViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            Text("testing")
            ImagePicker_LBTA(image: self.$avatarImage)
        }
        .onReceive(vm.$loggedIn) { loggedIn in
            if loggedIn { dismissView() }
        }
    }
    
    @ViewBuilder
    private var programView: some View {
        if programViewEnabled {
            VStack {
                Text("loading")
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.alpha0_5)
            .ignoresSafeArea()
        }
    }
    
    private var loginAndRegistrationPicker: some View {
        
        Picker(selection: $vm.isLoginMode,
               label: Text("Picker here")) {
            Text("Login")
                .tag(true)
            Text("Create Account")
                .tag(false)
        }.pickerStyle(SegmentedPickerStyle())
    }
    
    private var userInformationTextFields: some View {
        Group{
            TextField("Email", text: $vm.email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $vm.password)
            if !vm.isLoginMode {
                SecureField("Confirm Password", text: $vm.confirmPassword)
            }
        }
        .padding(12)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var imagePickerView: some View {
        if !vm.isLoginMode {
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                VStack {
                    if let image = self.avatarImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .cornerRadius(64)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 64))
                            .padding()
                            .foregroundColor(Color(.label))
                        
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 64)
                    .stroke(Color.black, lineWidth: 3))
            }
            
        }
    }
    
    private var submitButton: some View {
        Button {
            handlingSubmitAction()
        } label: {
            HStack {
                Spacer()
                Text(vm.isLoginMode ? "Login" : "Create Account")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }.background(vm.submitEnabled ? Color.blue : Color.gray)
        }
        .disabled(!vm.submitEnabled)
        
    }
    
    private var loginStatusMessageTextView: some View {
        Text(vm.statusMessage)
            .foregroundColor(.red)
    }
    
    // MARK: - Life Cycle
    
    init(){
        
    }
    
}

struct LoginAndRegistration_LBTA_Previews: PreviewProvider {
    static var previews: some View {
        
        LoginAndRegistration_LBTA()
    }
}
