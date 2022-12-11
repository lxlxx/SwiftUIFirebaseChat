//
//  FirebaseManager.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 15/10/2022.
//

import Foundation
import Firebase
import FirebaseStorage

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
    
    func fetchingAllCurrentUserChattingOpponentID(complete: @escaping (_ chattingOpponentID: String, _ message: [String: AnyObject]) -> ()){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let ref = FirebaseManager.shared.database.reference()
        let userRef = ref.child(GlobalString.userMessageDir).child(uid)
        
        userRef.observe(.childAdded) { snapshot in
            let chattingOpponentID = snapshot.key
            self.fetchingMessageByOpponentID(opponentID: chattingOpponentID) { message in
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
    
    func fetchingMessageByOpponentID(opponentID: String, complete: @escaping (_ message: [String: AnyObject]) -> ()) {
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
    
    func fetchingUserNameAndAvatar(uid: String, complete: @escaping (_ name: String, _ pic: String) -> ()){
        let ref = Database.database().reference().child(GlobalString.DB_user_dir).child(uid)

        ref.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                let name = value[GlobalString.DB_user_userName] as! String
                guard let imageURL = value[GlobalString.DB_user_profileImageUrl] as? String else { return }
                let pic = imageURL
                complete(name, pic)
                
            }
        }, withCancel: nil)
        
    }
    
    
    // MARK: send func
    
    func handlingSend(opponentID: String, chatText: String, complete:@escaping () -> ()) {
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
    
    // MARK: - View
    
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
