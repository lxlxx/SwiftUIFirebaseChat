//
//  FirebaseServices.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 3/3/2023.
//

import Foundation
import Combine
import Firebase
import FirebaseStorage
import FirebaseAuth

protocol FirebaseServices {
    var auth: Auth { get }
    var storage: Storage { get }
    var database: Database { get }
    
    
    func login(email: String, password: String) -> Future<Bool, Error>
    
    func createNewAccount(email: String, password: String) -> Future<Bool, Error>
    
    func fetchAllUsers() -> AnyPublisher<ChatUser, Error>
    
    func fetchAllChattingOpponentMessages() -> AnyPublisher<(any GeneralMessageContent)?, Never>
    
    func fetchCurrentUserInfo() ->Future<ChatUser, Error>
    
    func fetchAllCurrentUserChattingOpponentID() -> AnyPublisher<String?, Never>
    
    func fetchUserNameAndAvatar(opponent: RecentMessage) -> Future<RecentMessage, Never>
    
    func fetchAllMessagesByOpponentID(opponentID: String) -> AnyPublisher<DatabaseReference?, Never>
    
    func fetchMessageContentByMsgID(_ ref: DatabaseReference) -> AnyPublisher<(any GeneralMessageContent)?, Never>
    
    func sendImageMessage(opponentID: String, image: UIImage) -> Future<Bool, Error>
    
    func sendTextMessage(opponentID: String, chatText: String) -> Future<Bool, Error>
    
    func persistImageToStorage(imageData: Data) -> Future<(String, URL), Error>
    
    func updateUserInformation(email: String, uid: String,
                                         imageProfileUrl: URL,
                                         name: String,
                                         about: String) -> Future<Bool, Error>
}

extension FirebaseServices {
    func updateUserInformation(email: String,
                                 uid: String,
                                 imageProfileUrl: URL,
                                 name: String = "",
                                 about: String = "") -> Future<Bool, Error>
    {
        updateUserInformation(email: email,
                                uid: uid,
                                imageProfileUrl: imageProfileUrl,
                                name: name,
                                about: about)
    }
}
