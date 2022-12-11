//
//  NewMessageView_LBTA.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 17/10/2022.
//

import SwiftUI
import SDWebImageSwiftUI

class NewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    
    @Published var errorMsg = ""
    
    init() {
        fetchingAllUsers()
    }
    
    deinit {
        printLog("deinit")
    }
    
    private func fetchingAllUsers() {
        FirebaseManager.shared.fetchingAllUsers { user in
            self.users.append(user)
        } failed: {
            self.errorMsg = "fetch users failed"
        }

        
    }
}

struct NewMessageView_LBTA: View {
    // MARK: - Data
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var vm = NewMessageViewModel()
    
    // MARK: - Func
    
    // MARK: - View
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(vm.users) { user in
//                    cell(user)
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        NewMessageViewRowViewDetail(user: user)
                    }
                }
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }

                    }
                }
        }
    }
    
    // MARK: - Life Cycle
}

struct NewMessageViewRowViewDetail: View {
    let user: ChatUser
    
    var body: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: user.profilImage))
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipped()
                .cornerRadius(48)
                .overlay(RoundedRectangle(cornerRadius: 48)
                    .stroke(Color(.label), lineWidth: 1))
            Text("\(user.name)").foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal)
        
        Divider()
            .padding(.vertical, 8)
    }
    init(user: ChatUser) {
        self.user = user
    }
}

struct NewMessageView_LBTA_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView_LBTA { user in
            
        }
    }
}
