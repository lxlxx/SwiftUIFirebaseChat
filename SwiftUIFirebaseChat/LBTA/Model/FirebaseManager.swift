//
//  FirebaseManager.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 15/10/2022.
//

import Foundation
import Firebase
import FirebaseStorage
import Combine

// https://stackoverflow.com/questions/31443645/simplest-way-to-throw-an-error-exception-with-a-custom-message-in-swift
extension String: Error {}

class FirebaseManager: NSObject {
    
    // MARK: - Data
    let auth: Auth
    let storage: Storage
    let database: Database
    
    static let shared = FirebaseManager()
    
    var chatLogRef: DatabaseReference?
    
    // MARK: - Func
    
    func login_combine(email: String, password: String) -> Future<Bool, Error>  {
        Future { promise in
            FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
                result, err in
                if let err = err {
                    promise(.failure("Failed to login user \(err.localizedDescription)"))
                }
                promise(.success(true))
            }
        }
    }
    
    func login(email: String, password: String, complete: @escaping () -> () )  {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to login user", err)
                //                throw "Failed to login user \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            //            throw "Successfully logged in as user: \(result?.user.uid ?? "")"
            complete()
            
        }
    }
    
    func creatingNewAccount_combine(email: String, password: String) -> Future<Bool, Error>{
        Future { promise in
            FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
                result, err in
                if let err = err {
                    promise(.failure("Failed to create user \(err.localizedDescription)"))
                }
                promise(.success(true))
            }
        }
    }
    
    func creatingNewAccount(email: String, password: String, complete: @escaping () -> ()){
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user", err)
                //                self.loginStatusMessage = "Failed to create user \(err)"
                print(err)
                return
            }
            
            print("Successfully create user: \(result?.user.uid ?? "")")
            //            self.loginStatusMessage = "Successfully create user: \(result?.user.uid ?? "")"
            
            complete()
        }
    }
    
    func persistingImageToStorage_combine(imageData: Data) -> Future<(String, URL), Error> {
        Future { promise in
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                promise(.failure("uid not found"))
                return
            }
            
            let ref = FirebaseManager.shared.storage.reference()
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
    
    
    func persistingImageToStorage(imageData: Data ,complete: @escaping (_ uid: String, _ url: URL) -> () ){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.storage.reference()
            .child(GlobalString.DB_profilepics).child(uid)
        
        //        guard let imageData = imageData.jpegData(compressionQuality: 0.2) else { return }
        
        ref.putData(imageData) { metadata, err in
            if let err = err {
                //                self.loginStatusMessage = "Failed to push image to storage \(err)"
                print(err)
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    //                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(err)"
                    print(err)
                    return
                }
                //                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                print(url.absoluteString)
                complete(uid, url)
            }
        }
    }
    
    func updatingUserInformation_combine(email: String, uid: String, imageProfileUrl: URL, name: String = "", about: String = "") -> Future<Bool, Error> {
        
        Future { promise in
            let ref = FirebaseManager.shared.database.reference()
            let usersRef = ref.child("users").child(uid)
            
            let value = ["email": email, "name": name, "about": about, "pic": "\(imageProfileUrl)"] as [String : Any]
            
            usersRef.updateChildValues(value, withCompletionBlock: { (updateChildValuesErr, ref) in
                
                if updateChildValuesErr != nil {
                    promise(.failure("\(updateChildValuesErr?.localizedDescription)"))
                }
                promise(.success(true))
            })
        }
    }
    
    func updatingUserInformation(email: String, uid: String, imageProfileUrl: URL, name: String = "", about: String = "", complete: @escaping () -> ()) {
        let ref = FirebaseManager.shared.database.reference()
        let usersRef = ref.child("users").child(uid)
        
        let value = ["email": email, "name": name, "about": about, "pic": "\(imageProfileUrl)"] as [String : Any]
        
        usersRef.updateChildValues(value, withCompletionBlock: { (updateChildValuesErr, ref) in
            
            if updateChildValuesErr != nil {
                print(updateChildValuesErr!)
                return
            }
            
        })
    }
    
    func fetchingCurrentUserInfo_combine() ->Future<ChatUser, Error> {
        Future { promise in
            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                promise(.failure("Could not find uid"))
                return
            }
            
            let ref = FirebaseManager.shared.database.reference()
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
    
    func fetchingCurrentUserInfo(complete: @escaping (_ currentUserInfo: ChatUser) -> ()) throws {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            throw "Could not find uid"
        }
        
        let ref = FirebaseManager.shared.database.reference()
            .child(GlobalString.DB_user_dir).child(uid)
        
        ref.observeSingleEvent(of: .value) { snapshot, err in
            if let err = err {
                //                self.errorMessage = "err"
                print(err)
                return
            }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let currentUserInfo = ChatUser(uid: uid, dictionary: dictionary)
                complete(currentUserInfo)
                //                self.errorMessage = "\(dictionary.description)"
            } else {
                //                self.errorMessage = "snap err"
            }
        }
        
    }
    
    var cancellable = Set<AnyCancellable>()
    
    
    // https://medium.com/swlh/save-your-animation-code-from-callback-hell-with-combine-27b8a0961fa9
    // https://www.vadimbulavin.com/asynchronous-programming-with-future-and-promise-in-swift-with-combine-framework/
    // https://swiftrocks.com/avoiding-callback-hell-in-swift
    // https://www.vadimbulavin.com/tag/combine/
    // https://medium.com/@arlindaliu.dev/problem-solving-with-combine-swift-4751885fda77
    // https://medium.com/@o-p-e-n/creating-a-custom-combine-publisher-to-work-with-firebase-fbb9048c51f6
    // https://blog.canopas.com/use-firestore-and-firebase-realtime-database-with-combine-f7f865c0befc
    
    // https://stackoverflow.com/questions/72401569/show-custom-popup-view-on-top-of-view-hierarchy-swiftui
    
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
        //                .map { [ unowned self ] opponentID in
        //                    self.fetchingAllMessageByOpponentID_Combine(opponentID: opponentID)
        //                }
        //                .map { [ unowned self ] msgRef in
        //                    Task {
        //                        await self.fetchingMessageContentByMsgID_Combine(msgRef.value)
        //                    }
        //                }
        //                .sink { msg in
        //                    Task {
        //                        await promise(.success(("123", try msg.result.get().value)))
        //                    }
        //                }.store(in: &cancellable)
            
        
        
//        return Future { [unowned self] promise in
//            if #available(iOS 15.0, *) {
//                Task {
//                    self.fetchingAllCurrentUserChattingOpponentID_Combine().sink { <#String#> in
//                        <#code#>
//                    }.store(in: &cancellable)
//                    //                printLog("allOpponentID: \(await allOpponentID.value)")
//
////                    var allMessageByOpponentID = await self.fetchingAllMessageByOpponentID_Combine(opponentID: allOpponentID.value)
////                    //            printLog("allMessageByOpponentID: \(await allMessageByOpponentID.value)")
////                    var message = await self.fetchingMessageContentByMsgID_Combine(allMessageByOpponentID.value)
////                    //                printLog("message: \(await message.value)")
////                    await promise(Result.success((allOpponentID.value, message.value)))
//
//                }
//
//            }
//
//        }
//    }
    
    func fetchingAllCurrentUserChattingOpponentID_Combine() -> AnyPublisher<String?, Never> {
        let subject = CurrentValueSubject<String?, Never>(nil)
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return subject.eraseToAnyPublisher() }
        
        let ref = FirebaseManager.shared.database.reference()
        let userRef = ref.child(GlobalString.userMessageDir).child(uid)
        
        userRef.observe(.childAdded) { snapshot in
            let chattingOpponentID = snapshot.key
            subject.send(chattingOpponentID)
        }
        return subject.eraseToAnyPublisher()
        
//        return Future { promise in
//            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
//
//            let ref = FirebaseManager.shared.database.reference()
//            let userRef = ref.child(GlobalString.userMessageDir).child(uid)
//
//            userRef.observe(.childAdded) { snapshot in
//                let chattingOpponentID = snapshot.key
//                promise(.success(chattingOpponentID))
//            }
//        }
//        .eraseToAnyPublisher()
    }
    
    func fetchingAllMessageByOpponentID_Combine(opponentID: String) -> AnyPublisher<DatabaseReference?, Never> {
        let subject = CurrentValueSubject<DatabaseReference?, Never>(nil)
        guard let myID = FirebaseManager.shared.auth.currentUser?.uid else { return subject.eraseToAnyPublisher() }
            let toID = opponentID
            
            let userMessageDir = FirebaseManager.shared.database.reference().child(GlobalString.userMessageDir)
            let messageDir = FirebaseManager.shared.database.reference().child(GlobalString.messageDir)
            
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
    
    func fetchingAllCurrentUserChattingOpponentID(complete: @escaping (_ chattingOpponentID: String, _ message: [String: AnyObject]) -> ()){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.database.reference()
        let userRef = ref.child(GlobalString.userMessageDir).child(uid)
        
        userRef.observe(.childAdded) { snapshot in
            let chattingOpponentID = snapshot.key
            self.fetchingAllMessageByOpponentID(opponentID: chattingOpponentID) { message in
                complete(chattingOpponentID, message)
            }
//            let chatPartnersmessagesRef = FirebaseManager.shared.database.reference()
//                .child(GlobalString.userMessageDir)
//                .child(uid)
//                .child(chatPartnersID)
            //                .queryOrdered(byChild: "")
            //                .queryLimited(toLast: 1)
            
//            chatPartnersmessagesRef.observe(.childAdded, with: { (snapshot) in
//                let messageID = snapshot.key
//                let messagesRef = FirebaseManager.shared.database.reference()
//                    .child(GlobalString.messageDir)
//                    .child(messageID)
                
//                self.fetchMessageContentByID(messagesRef, chatPartnersID)
//            })
        }
    }
    
    
    func fetchingAllUsers(complete: @escaping (_ user: ChatUser) -> (), failed: @escaping () -> ()) {
        FirebaseManager.shared.database.reference().child(GlobalString.DB_user_dir).observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                
                if uid != snapshot.key {
                    let id = snapshot.key
//                    weakSelf?.users.append(.init(uid: id, dictionary: dictionary))
                    complete(ChatUser(uid: id, dictionary: dictionary))
                }
//                self.errorMsg = "fetch users success"
            } else {
                failed()
//                self.errorMsg = "fetch users failed"
            }
            }, withCancel: nil
        )
        
    }
    func fetchingAllUsers_Combine() -> AnyPublisher<ChatUser, Error> {
        
        let subject = PassthroughSubject<ChatUser, Error>()
        FirebaseManager.shared.database.reference().child(GlobalString.DB_user_dir).observe(.childAdded, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
                
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
    
    func fetchingAllMessageByOpponentID(opponentID: String, complete: @escaping (_ message: [String: AnyObject]) -> ()) {
        guard let myID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let toID = opponentID
        
        let userMessageDir = FirebaseManager.shared.database.reference().child(GlobalString.userMessageDir)
        let messageDir = FirebaseManager.shared.database.reference().child(GlobalString.messageDir)
        
        chatLogRef = userMessageDir.child(myID).child(toID)
        chatLogRef?.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = messageDir.child(messageID)
            
            self.fetchingMessageContentByMsgID(messagesRef) { msg in
                complete(msg)
            }
            
        }, withCancel: nil)
    }
        
    
    func fetchingMessageContentByMsgID(_ ref: DatabaseReference, complete:@escaping (_ message: [String: AnyObject]) -> () ){
        ref.observeSingleEvent(of:.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
//                self.appendMessage(dictionary)
                complete(dictionary)
            }
        })
    }
    
//    func fetchingUserNameAndAvatar(uid: String, complete: @escaping (_ name: String, _ pic: String) -> ()){
//        let ref = Database.database().reference().child(GlobalString.DB_user_dir).child(uid)
//
//        ref.observe(.value, with: { (snapshot) in
//            if let value = snapshot.value as? [String: AnyObject] {
//                let name = value[GlobalString.DB_user_userName] as! String
//                guard let imageURL = value[GlobalString.DB_user_profileImageUrl] as? String else { return }
//                let pic = imageURL
//                complete(name, pic)
//
//            }
//        }, withCancel: nil)
//
//    }
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
    
    func sendingMessage(opponentID: String, chatText: String, complete:@escaping () -> ()) {
        guard let fromID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let toID = opponentID
        
        let ref = FirebaseManager.shared.database.reference().child(GlobalString.messageDir)
        let childRef = ref.childByAutoId()
        let timestamp: NSNumber = NSNumber(integerLiteral: Int(Date().timeIntervalSince1970))
        let values = [GlobalString.toID: toID,
                      GlobalString.fromID: fromID,
                      GlobalString.timestamp: timestamp,
                      GlobalString.text: chatText as NSObject] as [String : Any]
        
//        contents.forEach{ values[$0] = $1 }
        
        childRef.updateChildValues(values){ error, ref in
            if let err = error {
                print(err); return
            }
            
            guard let messageID = childRef.key else { return }
            let userMessageDir = FirebaseManager.shared.database.reference().child(GlobalString.userMessageDir)
            
            let fromUserIDMessageRef = userMessageDir.child(fromID).child(toID)
            let toUserIDMessageRef = userMessageDir.child(toID).child(fromID)
            
            fromUserIDMessageRef.updateChildValues([messageID: timestamp])
            toUserIDMessageRef.updateChildValues([messageID: timestamp])
            
//            self.chatText = ""
            complete()
            
        }
    }
    
    
    // MARK: - Life Cycle
    
//    let currentUserID: String?
    
    
    override init() {
//        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.database = Database.database()
        
//        self.currentUserID = FirebaseManager.shared.auth.currentUser?.uid ?? nil
        
        super.init()
    }
}
