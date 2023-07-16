//
//  LoginAndRegistration.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 13/10/2022.
//


import SwiftUI


struct LoginAndRegistrationView: View {
    
    // MARK: - Data
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var vm = LoginAndRegistrationViewModel()
    
    @State private var shouldShowImagePicker = false
    
    @State private var avatarImage: UIImage?
    
    
    // MARK: - Func
    
    private func handlingSubmitAction() {
        vm.progressViewEnabled = true
        
        if vm.isLoginMode {
            vm.login()
        } else {
            vm.createNewAccount(image: avatarImage)
        }
    }
    
    private func dismissView() {
        vm.progressViewEnabled = false
        presentationMode.wrappedValue.dismiss()
    }
    
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 16){
                        
                        loginModePicker
                        
                        imagePickerView
                        
                        userInformationTextFields
                        
                        submitButton
                        
                        passwordStatusMessageTextView
                        
                        loginStatusMessageTextView
                        
                    }
                    .padding()
                }
                progressViewOverlay
                    
            }
            .navigationTitle(vm.isLoginMode ? GlobalString.loginText : GlobalString.createAccount)
            .background(Color(.init(white:0, alpha: 0.05))
                .ignoresSafeArea())
            
        }
        
        .fullScreenCover(isPresented: $shouldShowImagePicker) {

            ImagePicker_LBTA(image: $avatarImage)
        }
        .onReceive(vm.$loggedIn) { loggedIn in
            if loggedIn { dismissView() }
        }
        .onDisappear {
            vm.cancellables.removeAll()
        }
    }
    
    @ViewBuilder
    private var progressViewOverlay: some View {
        if vm.progressViewEnabled {
            VStack {
                Text("Loading")
                ProgressView()
                    .progressViewStyle(.circular)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.alpha0_5)
            .ignoresSafeArea()
        }
    }
    
    private var loginModePicker: some View {
        
        Picker(selection: $vm.isLoginMode,
               label: Text("Picker here")) {
            Text(GlobalString.loginText)
                .tag(true)
            Text(GlobalString.createAccount)
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
        .background(colorScheme == .dark ? Color.gray : Color.white)
        .autocapitalization(UITextAutocapitalizationType.none)
        
    }
    
    @ViewBuilder
    private var imagePickerView: some View {
        if !vm.isLoginMode {
            let strokeColor = vm.statusMessage == GlobalString.selectAnAvatar ? Color.red : Color.black
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                VStack {
                    if let image = avatarImage {
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
                    .stroke(strokeColor, lineWidth: 3))
                //TODO: add red color if not selected
            }
            
        }
    }
    
    private var submitButton: some View {
        Button {
            handlingSubmitAction()
        } label: {
            HStack {
                Spacer()
                Text(vm.isLoginMode ? GlobalString.loginText : GlobalString.createAccount)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
            }.background(vm.submitEnabled ? Color.blue : Color.gray)
        }
        .disabled(!vm.submitEnabled)
        
    }
    
    private var passwordStatusMessageTextView: some View {
        Text(vm.passwordStatusMessage)
            .foregroundColor(.red)
    }
    
    private var loginStatusMessageTextView: some View {
        Text(vm.statusMessage)
            .foregroundColor(.red)
    }
    
    // MARK: - Life Cycle
    
    init(){
        
    }
    
}

struct LoginAndRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        LoginAndRegistrationView()
        LoginAndRegistrationView().preferredColorScheme(.dark)
    }
}
