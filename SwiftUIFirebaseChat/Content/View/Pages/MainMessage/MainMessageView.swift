//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 15/10/2022.
//

import SwiftUI
import SDWebImageSwiftUI


struct MainMessageView: View {
    
    // MARK: - Data
    @State private var showingOptions = false
    
    @StateObject private var vm = MainMessageViewModel()
    
    @State private var newMessageScreenShown = false
    
    @State private var navigatingToChatLogView = false
    
    @State private var currentUser: ChatUser?
    
    private var chatLogVM = ChatLogViewModel(chatUser: nil)
    
    // MARK: - Func
    
    private func updatingChatLogViewModel(uid: String, name: String) {
        let temp = [GlobalString.DB_user_userName: name] as [String: AnyObject]
        currentUser = .init(uid: uid, dictionary: temp)
        chatLogVM.chatUser = currentUser
        chatLogVM.fetchMessages()
    }
    
    private func createChatLogView(vm: ChatLogViewModel) -> some View {
        return ChatLogView(chatUser: currentUser, vm: vm)
    }
    
    private func onDismissLoginAndRegistration() {
        
        vm.isUserCurrentlyLoggedOut = false
        vm.fetchCurrentUserInfo()
        vm.fetchCurrentMessage()
    }
    
    
    // MARK: - View
    
    var body: some View {
        VStack {
            
            customNavBar
            
            messageView
            
            NavigationLink("", isActive: $navigatingToChatLogView){
                
                ChatLogView(chatUser: currentUser, vm: chatLogVM)
            }
        }
        .navigationBarHidden(true)
        .overlay(
            newMessageButton, alignment: .bottom
        )
        .navigationViewStyle(StackNavigationViewStyle())
        
        .onDisappear {
//            vm.cancellables.removeAll()
        }
        
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: onDismissLoginAndRegistration) {
            LoginAndRegistrationView()
            
        }
        
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            UserAvatarView(url: vm.currentUser?.profileImage ?? "", size: CGSize(width: 48, height: 48))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.currentUser?.name.emailReplacement() ?? GlobalString.user_name)")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            Spacer()
            Button {
                showingOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
                
            }
            
        }
        .padding(.top, 8)
        .padding()
        .actionSheet(isPresented: $showingOptions) {
            ActionSheet(title: Text("Settings"), message: Text("What do you want to do"), buttons: [
                .destructive(Text("Sign out")) {
                    vm.handleSignOut()
                },
                .cancel()
            ])
        }
        
    }
    
    private var newMessageButton: some View {
        Button {
            newMessageScreenShown.toggle()
        } label: {
            VStack {
                HStack {
                    Spacer()
                    Text("+ New Message")
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
                Spacer().frame(height: 4)
            }
            .fullScreenCover(isPresented: $newMessageScreenShown) {
                NewMessageView { user in
                    print(user.email)
                    navigatingToChatLogView.toggle()
                    currentUser = user
                    chatLogVM.chatUser = currentUser
                    chatLogVM.fetchMessages()
                }
            }
        }
    }
    
    private var messageView: some View {
        ScrollView {
            ForEach(vm.recentOpponentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = String(recentMessage.uid)
                        let name = recentMessage.name
                        updatingChatLogViewModel(uid: uid, name: name)
                        navigatingToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            
                            UserAvatarView(url: recentMessage.profileImage, size: CGSize(width: 48, height: 48))
                            
                            VStack(alignment: .leading, spacing: 4 ) {
                                Text("\(recentMessage.name.emailReplacement())")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text("\(recentMessage.lastMessage)")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(.darkGray))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text("\(recentMessage.timeInFormattedString)")
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(Color(.label))
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                    
                }
                .padding(.horizontal)
                
            }
            .padding(.bottom, 60)
        }
    }
    
    // MARK: - Life Cycle
    
}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            MainMessageView()
        }
        
        //            .preferredColorScheme(.dark)
    }
}



