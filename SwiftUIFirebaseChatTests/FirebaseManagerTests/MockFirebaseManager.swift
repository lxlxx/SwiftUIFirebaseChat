//
//  MockFirebaseManager.swift
//  SwiftUIFirebaseChatTests
//
//  Created by yu fai on 3/3/2023.
//

import Foundation
import Combine
import Firebase
import FirebaseStorage

@testable import SwiftUIFirebaseChat

class MockFirebaseManager: NSObject, FirebaseServices {
    
    var auth: Auth
    
    var storage: FirebaseStorage.Storage
    
    var database: Database
    
    var cancellable = Set<AnyCancellable>()
    
    let mockFirebaseAuth = MockFirebaseAuth()
    
    
    override init() {
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.database = Database.database()
        
        super.init()
    }
    
}

extension MockFirebaseManager {
    // MARK: send func
    func sendImageMessage(opponentID: String, image: UIImage) -> Future<Bool, Error> {
        //TODO:
        return Future<Bool, Error> { promise in
                // TODO: Implement your image sending logic here
                
                // Return a default value for now
                promise(.success(false))
            }
        
    }
    
    func sendTextMessage(opponentID: String, chatText: String) -> Future<Bool, Error> {
        //TODO:
        return Future<Bool, Error> { promise in
                // TODO: Implement your text sending logic here
                
                // Return a default value for now
                promise(.success(false))
            }
    }
    
}

extension MockFirebaseManager {
    // MARK: - fetch user Func
    
    func fetchAllUsers() -> AnyPublisher<SwiftUIFirebaseChat.ChatUser, Error> {
        //TODO:
        
        return Empty<SwiftUIFirebaseChat.ChatUser, Error>().eraseToAnyPublisher()
    }
    func fetchAllCurrentUserChattingOpponentID() -> AnyPublisher<String?, Never> {
        //TODO:
        return Empty<String?, Never>().eraseToAnyPublisher()
    }
    
    func fetchCurrentUserInfo() -> Future<SwiftUIFirebaseChat.ChatUser, Error> {
        //TODO:
        return Future<SwiftUIFirebaseChat.ChatUser, Error> { promise in
                // Return a default value for now
                promise(.success(SwiftUIFirebaseChat.ChatUser(uid: "", dictionary: nil)))
            }
        }
    
    
    func fetchUserNameAndAvatar(opponent: SwiftUIFirebaseChat.RecentMessage) -> Future<SwiftUIFirebaseChat.RecentMessage, Never> {
        //TODO:
        return Future<SwiftUIFirebaseChat.RecentMessage, Never> { promise in
                // Return a default value for now
                promise(.success(opponent))
            }
    }
    
}

extension MockFirebaseManager {
    // MARK: - fetch message Func
    func fetchAllChattingOpponentMessages() -> AnyPublisher<(any SwiftUIFirebaseChat.GeneralMessageContent)?, Never> {
        //TODO:
        return Empty<(any SwiftUIFirebaseChat.GeneralMessageContent)?, Never>().eraseToAnyPublisher()
    }
    func fetchAllMessagesByOpponentID(opponentID: String) -> AnyPublisher<DatabaseReference?, Never> {
        //TODO:
        return Empty<DatabaseReference?, Never>().eraseToAnyPublisher()
    }
    
    func fetchMessageContentByMsgID(_ ref: DatabaseReference) -> AnyPublisher<(any SwiftUIFirebaseChat.GeneralMessageContent)?, Never> {
        //TODO:
        return Empty<(any SwiftUIFirebaseChat.GeneralMessageContent)?, Never>().eraseToAnyPublisher()
    }
    
}

extension MockFirebaseManager {
    // MARK: - Login and Registration Func
    
    func persistImageToStorage(imageData: Data) -> Future<(String, URL), Error> {
        Future { [unowned self] promise in
            self.mockFirebaseAuth.persistImageToStorage(imageData: imageData)
                .sink { completion in
                    switch completion {
                    case let .failure(error):
                        promise(.failure(error))
                    default: break
                    }
                } receiveValue: { result in
                    switch result {
                    case .success(let url, _):
                        promise(.success(("uid", URL(string: url!)!)))
                    case .failure(_, _):
                        break
                    case .unknown(_, _):
                        break
                    }
                }.store(in: &self.cancellable)
            
        }
    }


    
    func createNewAccount(email: String, password: String) -> Future<Bool, Error> {
        Future { promise in
            self.mockFirebaseAuth.createUser(withEmail: email, password: password) { dataResult in
                switch dataResult {
                case .success(_, _):
                    promise(.success(true))
                case .failure(_, let error):
                    promise(.failure(error!))
                case .unknown(_, let error):
                    promise(.failure(error!))
                }
            }
        }
    }
    
    func login(email: String, password: String) -> Future<Bool, Error> {
        Future { promise in
            self.mockFirebaseAuth.signIn(withEmail: email, password: password) { dataResult in
                switch dataResult {
                case .success(_, _):
                    promise(.success(true))
                case .failure(_, let error):
                    promise(.failure(error!))
                case .unknown(_, let error):
                    promise(.failure(error!))
                }
            }
        }
    }
}
