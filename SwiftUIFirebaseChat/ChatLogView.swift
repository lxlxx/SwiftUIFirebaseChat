//
//  ChatLogView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 20/12/2021.
//

import SwiftUI
import Firebase

struct ChatLogView: View {
    @Binding var chatIsShow: Bool
    
    @Binding var name: String
    @Binding var pic: String
    @Binding var uid: String
    
    @State var message: String = ""
    
    @State var currentMessages: [Message] = []
    
    
    var body: some View {
        VStack{
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { value in
                    VStack {
                        ForEach(currentMessages) { msg in
                            HStack {
                                if let messageContent = msg.text {
                                    if msg.messageFromCurrentUser() {
                                        Spacer()
                                    }
                                    Text(messageContent)
                                        .padding()
                                        .background(msg.messageFromCurrentUser() ? Color.blue : Color.green)
                                        .clipShape(ChatBubble(msg: msg))
                                        .foregroundColor(.white)
                                    if !msg.messageFromCurrentUser() {
                                        Spacer()
                                    }
                                    
                                }
                            }
                        }
                        .onChange(of: currentMessages.count) { _ in
                            value.scrollTo(currentMessages.count )
                        }
                    }
                    
                }
                    
            }
            
            Spacer()
            
            HStack {
                TextField("Enter Message", text: $message).textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button {
                    sendMessage()
                } label: {
                    Text("Send")
                }

            }
        }
        .padding()
        .navigationBarTitle(name, displayMode: .inline)
        .onAppear {
            fetchChatPartnerMessages()
        }
    }
    
    // MARK: fetch func
    
    func fetchChatPartnerMessages(){
        guard let myID = Auth.auth().currentUser?.uid else { return }
        let userMessageDir = Database.database().reference().child(GlobalString.userMessage)
        let messageDir = Database.database().reference().child(GlobalString.message)
        
        let ref = userMessageDir.child(myID).child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = messageDir.child(messageID)
            
            self.fetchMessageContentByID(messagesRef)
            
            }, withCancel: nil)
    }
    
    
    func fetchMessageContentByID(_ ref: DatabaseReference){
        ref.observeSingleEvent(of:.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.appendMessage(dictionary)
            }
        })
    }
    
    func appendMessage(_ dictionary: [String: AnyObject] ) {
        let messageIDCount = currentMessages.count + 1
        currentMessages.append(Message(dictionary, id: messageIDCount))
    }
    
    // MARK: send func
    
    private func sendMessage(){
        sendText()
    }
    
    // should handleSend and fetch result in a model like tweets
    fileprivate func handleSend(_ contents: [String: NSObject]) {
        let toUserID = uid
        guard let fromUserID = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let timestamp: NSNumber = NSNumber(integerLiteral: Int(Date().timeIntervalSince1970))
        var values = ["toID": toUserID, "fromID": fromUserID, "timestamp": timestamp] as [String : Any]
        
        contents.forEach{ values[$0] = $1 }
        
        childRef.updateChildValues(values){ error, ref in
            if let err = error {
                print(err); return
            }
            
            guard let messageID = childRef.key else { return }
            let userMessageDir = Database.database().reference().child(GlobalString.userMessage)
            
            let fromUserIDMessageRef = userMessageDir.child(fromUserID).child(toUserID)
            let toUserIDMessageRef = userMessageDir.child(toUserID).child(fromUserID)
            
            fromUserIDMessageRef.updateChildValues([messageID: 1])
            toUserIDMessageRef.updateChildValues([messageID: 1])
            
            
            
        }
        message = ""
    }
    
    private func sendText(){
        if message != "" {
            handleSend(["text":message as NSObject])
        }
    }
}


struct Message: Identifiable {
    
    var id: Int
    
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    var text: String?
    
    init(_ dict:[String: Any], id: Int) {
        self.id = id
        fromID = dict["fromID"] as? String
        text = dict["text"] as? String
        timestamp = dict["timestamp"] as? NSNumber
        toID = dict["toID"] as? String

    }
    
    func messageFromCurrentUser() -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return fromID == uid ? true : false
    }
    
    func chatPartnerID() -> String {
        return fromID == Auth.auth().currentUser?.uid ? toID! : fromID!
    }
}



struct ChatBubble: Shape {
    var msg: Message
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: [.topLeft,
                                                    .topRight,
                                                    msg.messageFromCurrentUser() ? .bottomLeft : .bottomRight],
                                cornerRadii: CGSize(width: 16, height: 8))
        return Path(path.cgPath)
    }
}










struct ChatLogView_Previews: PreviewProvider {
    
    struct BindingHolder: View {
        @State var show = true
        
        @State var uid = ""
        @State var name = ""
        @State var pic = ""
        
        var body: some View {
            ChatLogView(chatIsShow: $show, name: $uid, pic: $name, uid: $pic)
        }
    }
    
    static var previews: some View {
        BindingHolder()
    }
}

