//
//  Message.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 15/12/2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct MessageView: View {
    
    @State var show: Bool = false
    @State var chat: Bool = false
    
    @State var chatParter_uid = ""
    @State var name = ""
    @State var pic = ""
    
    @EnvironmentObject var homeMessage: MessageObserver
    
    var body: some View {
        ZStack{
            NavigationLink(destination: ChatLogView(chatIsShow: self.$chat,
                                                    name: self.$name,
                                                    pic: self.$pic,
                                                    uid: self.$chatParter_uid)
                           , isActive: self.$chat) {
                Text("")
            }
            VStack {
                ScrollView(.vertical , showsIndicators: false) {
                    VStack {
                        ForEach(homeMessage.recents) { msg in
                            HStack {
                                if let messageContent = msg.lastmsg {
                                    Button(action: {
                                        self.chat.toggle()
                                        self.name = msg.name
                                        self.pic = msg.pic
                                        self.chatParter_uid = msg.uid
                                    }) {
                                        RecentCellView(name: msg.name, pic: msg.pic, lastMsg: messageContent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Home", displayMode: .inline)
        .navigationBarItems(
            leading: signoutButton
            , trailing: newChatMessageButton
        )
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $show) {
            NewMessageView(show: $show, chat: $chat, uid: $chatParter_uid, name: $name, pic: $pic)
        }
    }
    
    var signoutButton: some View {
        Button(action: {
            try? Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: GlobalString.userStatus)
            NotificationCenter.default.post(name: Notification.Name(GlobalString.statusChange), object: nil)
        }, label: {
            Text("Sign out")
        })
    }
    
    var newChatMessageButton: some View {
        Button(action: {
            self.show.toggle()
        }, label: {
            Image(systemName: "square.and.pencil").resizable().frame(width: 25, height: 25, alignment: .center)
        })
    }
}

struct Message_Previews: PreviewProvider {
    
    static var previews: some View {
        MessageView()
    }
}

struct RecentCellView: View {
    var name: String
    var pic: String
    
    var lastMsg: String
    
    var body: some View {
        HStack {
            if let imageURL = URL(string: pic) {
                AnimatedImage(url: imageURL)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                
            }
            VStack {
                HStack {
                    Text(name).foregroundColor(.black)
                    Spacer()
                    
                }
                HStack {
                    Text(lastMsg).foregroundColor(.black)
                    Spacer()
                    
                }
                
                
            }
            Spacer()
        }
        .padding()
        
        Divider()
    }
}

class MessageObserver: ObservableObject {
    @Published var recents = [Recent]()
    
    var recentMessage = [String: Message]()
    
    var appendRecentMessageTimer: Timer?
    
    init() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference()
        let usersRef = ref.child(GlobalString.userMessage).child(uid)
        
        usersRef.observe(.childAdded) { snapshot in
            let chatPartnersID = snapshot.key
            let chatPartnersmessagesRef = Database.database().reference()
                .child(GlobalString.userMessage)
                .child(uid)
                .child(chatPartnersID)
            
            chatPartnersmessagesRef.observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                let messagesRef = Database.database().reference()
                    .child(GlobalString.message)
                    .child(messageID)
                
                self.fetchMessageContentByID(messagesRef)
            })
        }
    }
    
    //.queryOrdered(byChild: "metrics/views")
    //.queryLimited(toFirst: 100))!
    //https://firebase.google.com/docs/database/ios/lists-of-data#data_order
    
    func fetchMessageContentByID(_ ref: DatabaseReference){
        ref.observe(.value, with: { (snapshot) in
            // using smartMessage switch messagetype case text: append case video
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let id = self.recentMessage.count + 1
                self.recentMessage[Message(dictionary, id: id).chatPartnerID()] = Message(dictionary, id: id)
                self.appendRecentMessageTimer?.invalidate()
                self.appendRecentMessageTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.appendRecentMessage), userInfo: nil, repeats: false)

            }

            }, withCancel: nil)
    }
    
    @objc func appendRecentMessage(){
        let lastRectMessages = self.recentMessage.map { $0.1 }
        
        lastRectMessages.forEach { msg in
            fetchUserNameAndPic(msg: msg) { name, pic in
                let id = self.recents.count + 1
                guard let msgContent = msg.text, let msgTime = msg.timestamp else { return }
                self.recents.append(Recent(id: id,
                                           uid:msg.chatPartnerID(),
                                           name: name,
                                           pic: pic,
                                           lastmsg: msgContent,
                                           timestamp: msgTime)
                )
                
            }
        }
    }
    
    private func fetchUserNameAndPic (msg: Message, complete: @escaping (_ name: String, _ pic: String) -> ()){
        let ref = Database.database().reference().child(GlobalString.DB_user_dir).child(msg.chatPartnerID())

        ref.observe(.value, with: { (snapshot) in
            if let value = snapshot.value as? [String: AnyObject] {
                let name = value[GlobalString.DB_user_userName] as! String
                guard let imageURL = value[GlobalString.DB_user_profileImageUrl] as? String else { return }
                let pic = imageURL
                complete(name, pic)
                
            }
        }, withCancel: nil)
        
    }
}

struct Recent: Identifiable {
    var id: Int
    
    var uid: String
    
    var name: String
    var pic: String
    
    var lastmsg: String
    
    var timestamp: NSNumber
    
}

