//
//  ChatLogView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 18/10/2022.
//


import SwiftUI
import SDWebImageSwiftUI

struct ChatLogView: View, KeyboardReadable {
    
    // MARK: - Data
    
    private let bottomViewID = "bottomView"
    
    @ObservedObject var vm: ChatLogViewModel
    
    @State private var shouldShowImagePicker = false
    
    let chatUser: ChatUser?
    
    // MARK: - Func
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        proxy.scrollTo(bottomViewID, anchor: .bottom)
    }
    
    // MARK: - View
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if #available(iOS 15.0, *) {
                    messageView
                        .safeAreaInset(edge: .bottom) {
                            messageInputView
                        }
                } else {
                    messageView
                    messageInputView
                }
                
            }
            .environment(\.mainWindowSize, proxy.size)
            .onDisappear {
                vm.cancellables.removeAll()
            }
            
        }
        
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: {
            vm.sendImageMessage()
        }) {
            ImagePicker_LBTA(image: $vm.imageSelected)
        }
        
    }
    
    
    private var messageView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { value in
                    VStack {
                        ForEach(vm.chatMessages) { msg in
                            ChatLogRowView(content: msg.message)
                        }
                        .onAppear(){
                            scrollToBottom(proxy: value)
                        }
                        
                        HStack { Spacer() }
                            .id(bottomViewID)
                    }
                    .onChange(of: vm.chatMessages.count) { _ in
                        scrollToBottom(proxy: value)
                    }
                    .onReceive(keyboardPublisher) { _ in
                        scrollToBottom(proxy: value)
                    }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .navigationTitle("\(chatUser?.name.emailReplacement() ?? "")")
            
        }
    }
    
    private var messageInputView: some View {
        HStack(spacing: 16) {
            Button {
                shouldShowImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }
            TextField("message", text: $vm.chatText)
            Button {
                vm.sendTextMessage()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
    
    
    // MARK: - Life Cycle
    
    init(chatUser: ChatUser?, vm: ChatLogViewModel) {
        self.chatUser = chatUser
        self.vm = vm
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        let temp = ["name": "joel"] as [String: AnyObject]

        NavigationView {
            let chatOpponent = ChatUser(uid: "J057oK0WKLMQFWzz8G8DEvGSpP42", dictionary: temp)
            let vm = ChatLogViewModel(chatUser: chatOpponent)
            ChatLogView(chatUser: chatOpponent, vm: vm)
        }
            
        
    }
}




