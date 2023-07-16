//
//  MainMessageViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI
import Firebase
import Combine


class MainMessageViewModel: ObservableObject {
    
    // MARK: - Data
    
    @Published var errorMessage = ""
    @Published var currentUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    @Published var recentOpponentMessages = [RecentMessage]() {
        didSet {
            
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    private let firebaseServices: FirebaseServices
    
    // MARK: - Life Cycle
    
    
    
    init(firebaseServices: FirebaseServices = FirebaseManagerDI()) {
        self.firebaseServices = firebaseServices
        DispatchQueue.main.async { [weak self] in
            self?.isUserCurrentlyLoggedOut = firebaseServices.auth.currentUser?.uid == nil
        }
        
        fetchCurrentMessage()
        
        fetchCurrentUserInfo()
        
        
    }
    
    deinit {
        printLog(GlobalString.deinitText)
    }
    
    // MARK: - Func

    func fetchCurrentMessage(){
        
        firebaseServices.fetchAllChattingOpponentMessages()
            .compactMap { $0 }
            .sink { [weak self] msg in
                self?.updateCurrentMessage(msg: msg, oppID: msg.chatPartnerID())
            }.store(in: &cancellables)
    }
    
    func handleSignOut(){
        isUserCurrentlyLoggedOut = true
        try? firebaseServices.auth.signOut()
        self.recentOpponentMessages = []
    }
    
    
    func fetchCurrentUserInfo(){
        firebaseServices.fetchCurrentUserInfo()
            .sink { [weak self] completion in
                switch completion {
                case let .failure(error):
                    guard let err = error as? String else { return }
                    self?.errorMessage = err
                default: break
                }
                
            } receiveValue: { [weak self] currentUserInfo in
                self?.currentUser = currentUserInfo
            }.store(in: &cancellables)

    }
    
    func updateCurrentMessage(msg: any GeneralMessageContent, oppID opponentUID: String){
        var opponentLastMsg = msg
        
        if let opponent = self.recentOpponentMessages.first(where: { $0.uid == opponentUID })
        {
            let msgID = opponent.message.count
            opponentLastMsg.id = msgID
            opponent.message.append(opponentLastMsg)
            
        } else {
            let recentMessageID = self.recentOpponentMessages.count + 1
            let lastMsg = opponentLastMsg.contentInText
            guard let timestamp = opponentLastMsg.timestamp else { return }
            let opponentRecentMessage = RecentMessage(id: recentMessageID,
                                                      uid:opponentUID,
                                                      lastMessage: lastMsg,
                                                      timestamp: timestamp)
            opponentRecentMessage.message.append(opponentLastMsg)
            self.recentOpponentMessages.append(opponentRecentMessage)
            self.updateOpponentNameAndPic(opponent: opponentRecentMessage)
        }
        self.recentOpponentMessages.sort()
    }
    
    
    func updateOpponentNameAndPic(opponent: RecentMessage){
        
        firebaseServices.fetchUserNameAndAvatar(opponent: opponent)
            .sink { [weak self] opponent in
                if let index = self?.recentOpponentMessages.firstIndex(where: {$0.uid == opponent.uid }) {
                    self?.recentOpponentMessages[index] = opponent
                }
            }.store(in: &cancellables)
        
    }
}
