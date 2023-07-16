//
//  ChatLogViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI
import Combine
import Firebase

class ChatLogViewModel: ObservableObject {
    @Published var chatText = ""
    
    @Published var chatMessages: [AnyMessageContent] = []
    
    @Published var imageSelected: UIImage?
    
    var cancellables = Set<AnyCancellable>()
    
    var chatUser: ChatUser?
    
    private var firebaseServices: FirebaseServices
    
    
    init(chatUser: ChatUser?, firebaseServices: FirebaseServices = FirebaseManagerDI()) {
        self.firebaseServices = firebaseServices
        self.chatUser = chatUser
        
//        fetchMessages()
    }
    
    deinit {
        printLog(GlobalString.deinitText)
    }
    
    
    // MARK: fetch message with partner func
    
    func removeAllChatMessages() {
        chatMessages.removeAll()
    }
    func fetchMessages() {
        guard let opponentID = chatUser?.uid else { return }
        
        removeAllChatMessages()
        
        firebaseServices.fetchAllMessagesByOpponentID(opponentID: opponentID)
            .compactMap{ $0 }
            .flatMap { [unowned self] ref in
                self.firebaseServices.fetchMessageContentByMsgID(ref)
            }
            .compactMap{ $0 }
            .sink { _ in
                
            } receiveValue: { [weak self] msg in
                self?.appendMessage(msg)
            }
            .store(in: &cancellables)

    }
    
    func appendMessage(_ msg: any GeneralMessageContent ) {
        var lastMsg = AnyMessageContent(msg)
        let messageIDCount = chatMessages.count + 1
        lastMsg.id = messageIDCount
        chatMessages.append(lastMsg)
    }
    
    
    // MARK: send func
    func sendImageMessage() {
        guard let toID = chatUser?.uid, let imageSelected = imageSelected else { return }
        
        firebaseServices.sendImageMessage(opponentID: toID, image: imageSelected)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                default: break
                }
            } receiveValue: { [unowned self] result in
                if result { self.imageSelected = nil }
            }
            .store(in: &cancellables)

    }
    
    func sendTextMessage() {
        guard let toID = chatUser?.uid, chatText != "" else { return }
        
        firebaseServices.sendTextMessage(opponentID: toID, chatText: chatText)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                default: break
                }
            } receiveValue: { [unowned self] result in
                if result { self.chatText = "" }
            }
            .store(in: &cancellables)

    }
}
