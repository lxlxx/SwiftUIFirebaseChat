//
//  NewMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 16/12/2021.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct NewMessageView: View {
    @Binding var show: Bool
    @Binding var chat: Bool
    
    @Binding var uid: String
    @Binding var name: String
    @Binding var pic: String
    
    @ObservedObject var allUserData = allFirebaseChatUser()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { _ in
                VStack(alignment: .leading) {
                    backButton
                    userList
                    
                }
            }
            
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
    }
    
    var userList: some View {
        VStack(alignment: .leading) {
            if self.allUserData.users.count == 0 {
                Text("No Users Found")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack() {
                        ForEach(allUserData.users) { user in
                            Button(action: {
                                self.uid = user.id
                                self.name = user.name
                                self.pic = user.pic
                                
                                self.show.toggle()
                                self.chat.toggle()
                            }){
                                UserCellView(name: user.name ,pic: user.pic)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var backButton: some View {
        HStack {
            ZStack {
                Color.blue
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
                Button(action:{
                    self.show.toggle()
                }){
                    Image(systemName: "chevron.left").font(.title).foregroundColor(.white)
                }
                
            }
            
        }
        .padding()
    }
}



struct UserCellView: View {
    var name: String
    var pic: String
    
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
                Text(name).foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        
        Divider()
    }
}





class allFirebaseChatUser: ObservableObject {
    
    @Published var users = [User]()
    @Published var empty = true
    
    init() {
        Database.database().reference().child(GlobalString.DB_user_dir).observe(.childAdded, with: { [ weak weakSelf = self ] (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                if uid != snapshot.key {
                    let id = snapshot.key
                    let name = dictionary[GlobalString.DB_user_userName] as! String
                    if let pic = dictionary[GlobalString.DB_message_pic] as? String {
                        weakSelf?.addUser(id: id, name: name, pic: pic)
                    } else if let pic = dictionary[GlobalString.DB_user_profileImageUrl] as? String {
                        weakSelf?.addUser(id: id, name: name, pic: pic)
                    } else {
                        weakSelf?.addUser(id: id, name: name, pic: "")
                    }
                }
                
            }
            }, withCancel: nil
        )
        
        
    }
    
    private func addUser(id: String, name: String, pic: String, about: String = "") {
        users.append(User(id: id, name: name, pic: pic, about: about))
        if empty {
            empty = false
        }
    }
    
}

struct User: Identifiable {
    var id: String
    var name: String
    var pic: String
    var about: String
}






struct NewMessageView_Previews: PreviewProvider {
    struct BindingHolder: View {
        @State var show = true
        @State var chat = false
        
        @State var uid = ""
        @State var name = ""
        @State var pic = ""
        
        var body: some View {
            NewMessageView(show: $show, chat: $chat, uid: $uid, name: $name, pic: $pic)
        }
    }
    
    static var previews: some View {
        BindingHolder()
    }
}
