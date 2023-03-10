//
//  FirebaseManagerDI.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 10/3/2023.
//

//Singleton vs Dependency Injection in Swift
//https://getstream.io/blog/singleton-dependency-injection-in-swift/

import Foundation
import Firebase
import FirebaseStorage
import Combine
import FirebaseAuth

class FirebaseManagerDI: NSObject, FirebaseServices {
    
    // MARK: - Data
    let auth: Auth
    let storage: Storage
    let database: Database
    
    var chatLogRef: DatabaseReference?
    
    var cancellable = Set<AnyCancellable>()
    
    // MARK: - Func
    
    func login_combine(email: String, password: String) -> Future<Bool, Error>  {
        Future { promise in
            self.auth.signIn(withEmail: email, password: password) {
                result, err in
                if let err = err {
                    promise(.failure("Failed to login user \(err.localizedDescription)"))
                }
                promise(.success(true))
            }
        }
        
    }
    
    
    func creatingNewAccount_combine(email: String, password: String) -> Future<Bool, Error>{
        Future { promise in
            self.auth.createUser(withEmail: email, password: password) {
                result, err in
                if let err = err {
                    promise(.failure("Failed to create user \(err.localizedDescription)"))
                }
                promise(.success(true))
            }
        }
    }
    
    
    
    func persistingImageToStorage_combine(imageData: Data) -> Future<(String, URL), Error> {
        Future { promise in
            guard let uid = self.auth.currentUser?.uid else {
                promise(.failure("uid not found"))
                return
            }
            
            let ref = self.storage.reference()
                .child(GlobalString.DB_profilepics).child(uid)
            
            ref.putData(imageData) { metadata, err in
                if let err = err {
                    promise(.failure("\(err)"))
                }
                
                ref.downloadURL { url, err in
                    if let err = err {
                        promise(.failure("\(err)"))
                    }
                    
                    guard let url = url else {
                        promise(.failure("url not found"))
                        return
                    }
                    promise(.success((uid, url)))
                    
                }
            }
        }
    }
    
    
    func updatingUserInformation_combine(email: String,
                                         uid: String,
                                         imageProfileUrl: URL,
                                         name: String = "",
                                         about: String = "") -> Future<Bool, Error>
    {
        
        Future { promise in
            let ref = self.database.reference()
            let usersRef = ref.child("users").child(uid)
            
            let value = [GlobalString.email: email,
                         GlobalString.DB_user_userName: email,
                         GlobalString.DB_user_profileImageUrl: "\(imageProfileUrl)"] as [String : Any]
            
            usersRef.updateChildValues(value, withCompletionBlock: { (updateChildValuesErr, ref) in
                
                if updateChildValuesErr != nil {
                    promise(.failure("\(String(describing: updateChildValuesErr?.localizedDescription))"))
                }
                promise(.success(true))
            })
        }
    }
    
    
    
    func fetchingCurrentUserInfo_combine() ->Future<ChatUser, Error> {
        Future { promise in
            guard let uid = self.auth.currentUser?.uid else {
                promise(.failure("Could not find uid"))
                return
            }
            
            let ref = self.database.reference()
                .child(GlobalString.DB_user_dir).child(uid)
            
            ref.observeSingleEvent(of: .value) { snapshot, err in
                if let err = err {
                    promise(.failure("\(err)"))
                    return
                }
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let currentUserInfo = ChatUser(uid: uid, dictionary: dictionary)
                    promise(.success(currentUserInfo))
                    
                }
            }
        }
    }
    
    
    func fetchingAllChattingOpponentMessage() -> AnyPublisher<Message?, Never> {
        let subject = CurrentValueSubject<Message?, Never>(nil)
        self.fetchingAllCurrentUserChattingOpponentID_Combine()
            .compactMap { $0 }
            .flatMap { [ unowned self ] opponentID in
                self.fetchingAllMessageByOpponentID_Combine(opponentID: opponentID)
            }
            .compactMap { $0 }
            .flatMap { [ unowned self ] msgRef in
                self.fetchingMessageContentByMsgID_Combine(msgRef)
            }
            .compactMap { $0 }
            .sink { msg in
                subject.send(msg)
            }
            .store(in: &cancellable)
        return subject.eraseToAnyPublisher()
        
    
    }
    
    func fetchingAllCurrentUserChattingOpponentID_Combine() -> AnyPublisher<String?, Never> {
        let subject = CurrentValueSubject<String?, Never>(nil)
        guard let uid = self.auth.currentUser?.uid else { return subject.eraseToAnyPublisher() }
        
        let ref = self.database.reference()
        let userRef = ref.child(GlobalString.userMessageDir).child(uid)
        
        userRef.observe(.childAdded) { snapshot in
            let chattingOpponentID = snapshot.key
            subject.send(chattingOpponentID)
        }
        return subject.eraseToAnyPublisher()
    }
    
    func fetchingAllMessageByOpponentID_Combine(opponentID: String) -> AnyPublisher<DatabaseReference?, Never> {
        let subject = CurrentValueSubject<DatabaseReference?, Never>(nil)
        guard let myID = self.auth.currentUser?.uid else { return subject.eraseToAnyPublisher() }
            let toID = opponentID
            
            let userMessageDir = self.database.reference().child(GlobalString.userMessageDir)
            let messageDir = self.database.reference().child(GlobalString.messageDir)
            
            userMessageDir.child(myID).child(toID).observe(.childAdded, with: { (snapshot) in
                
                let messageID = snapshot.key
                let messagesRef = messageDir.child(messageID)
                
                subject.send(messagesRef)
                
            }, withCancel: nil)
            
        return subject.eraseToAnyPublisher()
    }
    
    func fetchingMessageContentByMsgID_Combine(_ ref: DatabaseReference) -> AnyPublisher<Message?, Never> {
        let subject = CurrentValueSubject<Message?, Never>(nil)
        ref.observeSingleEvent(of:.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                subject.send(Message(dictionary, id: 0))
            }
        })
        return subject.eraseToAnyPublisher()
    }
    
    
    
    func fetchingAllUsers_Combine() -> AnyPublisher<ChatUser, Error> {
        
        let subject = PassthroughSubject<ChatUser, Error>()
        self.database.reference().child(GlobalString.DB_user_dir).observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                guard let uid = self.auth.currentUser?.uid else { return }
                
                if uid != snapshot.key {
                    let id = snapshot.key
                    subject.send(ChatUser(uid: id, dictionary: dictionary))
                }
                
            } else {
                subject.send(completion: .failure("can't find users"))
            }
        }, withCancel: nil
        )
        
        return subject.eraseToAnyPublisher()
    }
    
    
    func fetchingUserNameAndAvatar_Combine(opponent: RecentMessage_Class) -> Future<RecentMessage_Class, Never>{
        return Future { promise in
            
            let ref = Database.database().reference().child(GlobalString.DB_user_dir).child(opponent.uid)
            
            ref.observe(.value, with: { (snapshot) in
                if let value = snapshot.value as? [String: AnyObject] {
                    guard let imageURL = value[GlobalString.DB_user_profileImageUrl] as? String,
                          let name = value[GlobalString.DB_user_userName] as? String else { return }
                    opponent.name = name
                    opponent.pic = imageURL
                    
                    promise(.success(opponent))
                    
                }
            }, withCancel: nil)
        }
        
    }
    
    func fetchingUserNameAndAvatar_Combine(opponent: RecentMessage) -> Future<RecentMessage, Never>{
        var myOpponent = opponent
        return Future { promise in
            
            let ref = Database.database().reference().child(GlobalString.DB_user_dir).child(opponent.uid)
            
            ref.observe(.value, with: { (snapshot) in
                if let value = snapshot.value as? [String: AnyObject] {
                    guard let imageURL = value[GlobalString.DB_user_profileImageUrl] as? String,
                          let name = value[GlobalString.DB_user_userName] as? String else { return }
                    myOpponent.name = name
                    myOpponent.pic = imageURL
                    
                    promise(.success(myOpponent))
                    
                }
            }, withCancel: nil)
        }
        
    }
    
    // MARK: send func
    
    func sendTextMessage(opponentID: String, chatText: String) -> Future<Bool, Error> {
        Future { [unowned self] promise in
            self.sendingMessage(opponentID: opponentID, contents: [GlobalString.text: chatText as NSObject])
                .sink { completion in
                    switch completion {
                    case let .failure(error):
                        promise(.failure(error))
                    default: break
                    }
                } receiveValue: { result in
                    promise(.success(result))
                }
                .store(in: &self.cancellable)
        }
    }
    
    func sendImageMessage(opponentID: String, image: UIImage) -> Future<Bool, Error> {
        Future { [unowned self] promise in
            storageImage(image)
                .flatMap { contents -> AnyPublisher<Bool, Error> in
                    self.sendingMessage(opponentID: opponentID, contents: contents).eraseToAnyPublisher()
                }
                .sink { completion in
                    switch completion {
                    case let .failure(error):
                        promise(.failure(error))
                    default: break
                    }
                } receiveValue: { result in
                    promise(.success(result))
                }
                .store(in: &self.cancellable)
        }
    }
    
    func storageImage(_ imageWillUpload: UIImage) -> Future<[String: NSObject], Error> {
        Future { promise in
            let imageName = UUID().uuidString
            let ref = self.storage.reference().child(GlobalString.DB_message_image).child("\(imageName).png")
            
            if let compressedImage = compressImage(imageWillUpload) {
                ref.putData(compressedImage, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!) ;
                        return
                    }
                    
                    ref.downloadURL(completion:{ url, error in
                        if error != nil, url == nil {
                            print(error!) ;
                            return
                        }
                        if let imageURL = url?.absoluteString {
                            let contents = [GlobalString.message_imageURL: imageURL as NSObject,
                                            GlobalString.message_imageWidth: imageWillUpload.size.width as NSObject, GlobalString.message_imageHeight: imageWillUpload.size.height as NSObject]
                            promise(.success(contents))
                        }
                    })
                })
            }
        }
    }
    
    func sendingMessage(opponentID: String, contents: [String: NSObject]) -> Future<Bool, Error> {
        Future { promise in
            guard let fromID = self.auth.currentUser?.uid else { return }
            let toID = opponentID
            
            let ref = self.database.reference().child(GlobalString.messageDir)
            let childRef = ref.childByAutoId()
            let timestamp: NSNumber = NSNumber(integerLiteral: Int(Date().timeIntervalSince1970))
            var values = [GlobalString.toID: toID,
                          GlobalString.fromID: fromID,
                          GlobalString.timestamp: timestamp] as [String : Any]
            
            contents.forEach{ values[$0] = $1 }
            
            childRef.updateChildValues(values){ error, ref in
                if let err = error {
                    print(err);
                    promise(.failure(err))
                }
                
                guard let messageID = childRef.key else { return }
                let userMessageDir = self.database.reference().child(GlobalString.userMessageDir)
                
                let fromUserIDMessageRef = userMessageDir.child(fromID).child(toID)
                let toUserIDMessageRef = userMessageDir.child(toID).child(fromID)
                
                fromUserIDMessageRef.updateChildValues([messageID: timestamp])
                toUserIDMessageRef.updateChildValues([messageID: timestamp])
                
                promise(.success(true))
                
            }
        }
    }
    
    
    // MARK: - Life Cycle
    
    
    override init() {
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.database = Database.database()
        
        super.init()
    }
}
