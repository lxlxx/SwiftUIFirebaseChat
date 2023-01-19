//
//  LoginAndRegistration_LBTA.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 13/10/2022.
//

import SwiftUI
import Combine

class LoginAndRegistration_LBTA_ViewModel: ObservableObject {
    
    // MARK: - Data
    @Published var email = ""
    @Published var password = ""
    @Published var statusMessage = ""
    
    @Published var loggedIn = false
    
    private var cancellable = Set<AnyCancellable>()
    
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
    
    
}

struct LoginAndRegistration_LBTA: View {
    
    // MARK: - Data
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var vm = LoginAndRegistration_LBTA_ViewModel()
    
    @State private var isLoginMode = true
    
    @State private var shouldShowImagePicker = false
    
    @State var avatarImage: UIImage?
    
    
    // MARK: - Func
    
    private func handlingSubmitAction() {
        if isLoginMode {
            vm.login()
        } else {
            vm.creatingNewAccount(image: avatarImage)
        }
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
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
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
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
    
    private var loginAndRegistrationPicker: some View {
        
        Picker(selection: $isLoginMode,
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
        }
        .padding(12)
        .background(Color.white)
    }
    
    @ViewBuilder
    private var imagePickerView: some View {
        if !isLoginMode {
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
                Text(isLoginMode ? "Login" : "Create Account")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }.background(Color.blue)
        }
    }
    
    private var loginStatusMessageTextView: some View {
        Text(vm.statusMessage)
            .foregroundColor(.red)
    }
    
    // MARK: - Life Cycle
    
    
    
}

struct LoginAndRegistration_LBTA_Previews: PreviewProvider {
    static var previews: some View {
        
        LoginAndRegistration_LBTA()
    }
}
