//
//  LoginAndRegistration_LBTA.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 13/10/2022.
//

import SwiftUI


struct LoginAndRegistration_LBTA: View {
    
    // MARK: - Data
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    
    @State var shouldShowImagePicker = false
    
    @State var image: UIImage?
    
    @State var loginStatusMessage = ""
    
    // MARK: - Func
    
    private func handlingSubmitAction() {
        if isLoginMode {
            login()
            print("login")
        } else {
            creatingNewAccount()
            print("Register")
        }
    }
    
    private func login() {
        FirebaseManager.shared.login(email: self.email, password: self.password){
            self.didCompleteLoginProcess()
        }
    }
    
    private func creatingNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
        }
        
        FirebaseManager.shared.creatingNewAccount(email: self.email, password: self.password) {
            self.persistingImageToStorage()
        }
    }
    
    private func persistingImageToStorage() {
        guard let imageData = self.image?.jpegData(compressionQuality: 0.2) else { return }
        FirebaseManager.shared.persistingImageToStorage(imageData: imageData) { uid, url in
            self.updatingUserInformation(uid: uid, imageProfileUrl: url)
        }
    }
    
    private func updatingUserInformation(uid: String, imageProfileUrl: URL, name: String = "", about: String = ""){
        FirebaseManager.shared.updatingUserInformation(email: email, uid: uid, imageProfileUrl: imageProfileUrl) {
            self.didCompleteLoginProcess()
        }
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
            ImagePicker_LBTA(image: $image)
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
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
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
                    if let image = self.image {
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
        Text(self.loginStatusMessage)
            .foregroundColor(.red)
    }
    
    // MARK: - Life Cycle
    
    
    
}

struct LoginAndRegistration_LBTA_Previews: PreviewProvider {
    static var previews: some View {
        LoginAndRegistration_LBTA(didCompleteLoginProcess: {})
    }
}
