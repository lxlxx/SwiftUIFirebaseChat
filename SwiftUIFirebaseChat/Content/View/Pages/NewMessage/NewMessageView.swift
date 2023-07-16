//
//  NewMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 17/10/2022.
//

import SwiftUI
import SDWebImageSwiftUI


struct NewMessageView: View {
    // MARK: - Data
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) private var presentationMode
    
    @ObservedObject private var vm = NewMessageViewModel()
    
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
                        NewMessageViewRowView(user: user)
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
        .onDisappear {
            vm.cancellables.removeAll()
        }
    }
    
    // MARK: - Life Cycle
}



struct NewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        NewMessageView { user in
            
        }
        
    }
}
