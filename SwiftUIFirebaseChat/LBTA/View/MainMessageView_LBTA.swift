//
//  MainMessageView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 15/10/2022.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import Combine

// https://stackoverflow.com/questions/28727845/find-an-object-in-array


class MainMessageViewModel: ObservableObject {
    
    // MARK: - Data
    
    @Published var errorMessage = ""
    @Published var currentUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    @Published var recentOpponentMessage = [RecentMessage_Class]() {
        didSet {
            //sortting in here always crash the xcode, dont know why - 20221206
            //            recents.sort()
        }
    }
    
    //key: value = chatPartnerID: Message
    //    var recentMessage = [String: Message]()
    
//    var appendRecentMessageTimer: Timer?
    
//    var userRef: DatabaseReference?
    
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    
    
    
    init() {
        DispatchQueue.main.async { [weak self] in
            self?.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentMessage_Combine()
        
        fetchingCurrentUserInfo()
        
        
//        fetchCurrentMessage_Combine()
        
//        FirebaseManager.shared.fetchingAllCurrentUserChattingOpponentID_Combine()
//            .sink { [weak self] opponentID in
//                self?.errorMessage += opponentID
//            }.store(in: &cancellable)
    }
    
    deinit {
//        printLog("deinit")
    }
    
    // MARK: - Func

    func fetchCurrentMessage_Combine(){
        
        FirebaseManager.shared.fetchingAllChattingOpponentMessage()
            .compactMap { $0 }
            .sink { [weak self] msg in
                self?.updatingCurrentMessage(msg: msg, oppID: msg.chatPartnerID())
            }.store(in: &cancellable)
    }
    
    func handlingSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
    
    func fetchingCurrentUserInfo(){
        do {
            try FirebaseManager.shared.fetchingCurrentUserInfo { currentUserInfo in
                self.currentUser = currentUserInfo
            }
        } catch {
            guard let err = error as? String else { return }
            self.errorMessage = err
        }
    }
    
    
    func fetchCurrentMessage() {
        self.recentOpponentMessage.removeAll()
//        self.recentMessage.removeAll()
//        self.userRef?.removeAllObservers()
        FirebaseManager.shared.fetchingAllCurrentUserChattingOpponentID { [weak self] chattingOpponentID, message in
            self?.updatingCurrentMessage(data: message, chattingOpponentID)
        }
//        FirebaseManager.shared.fetchingAllChattingOpponentMessage()
//            .compactMap { $0 }
//            .sink { [weak self] msg in
//                self?.updatingCurrentMessage(msg: msg, oppID: msg.chatPartnerID())
//            }.store(in: &cancellable)
        
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
//
//        let ref = FirebaseManager.shared.database.reference()
//        self.userRef = ref.child(GlobalString.userMessageDir).child(uid)
//
//        self.userRef?.observe(.childAdded) { snapshot in
//            let chatPartnersID = snapshot.key
//            let chatPartnersmessagesRef = FirebaseManager.shared.database.reference()
//                .child(GlobalString.userMessageDir)
//                .child(uid)
//                .child(chatPartnersID)
////                .queryOrdered(byChild: "")
////                .queryLimited(toLast: 1)
//
//            chatPartnersmessagesRef.observe(.childAdded, with: { (snapshot) in
//                let messageID = snapshot.key
//                let messagesRef = FirebaseManager.shared.database.reference()
//                    .child(GlobalString.messageDir)
//                    .child(messageID)
//
//                self.fetchMessageContentByID(messagesRef, chatPartnersID)
//            })
//        }
    }

    
    //.queryOrdered(byChild: "metrics/views")
    //.queryLimited(toFirst: 100))!
    //https://firebase.google.com/docs/database/ios/lists-of-data#data_order
    
//    func fetchMessageContentByID(_ ref: DatabaseReference, _ opponentUID: String){
//        ref.observe(.value, with: { (snapshot) in
//
//            if let dictionary = snapshot.value as? [String: AnyObject] {
//                self.updatingCurrentMessage(data: dictionary, opponentUID)
//            }
//
//            }, withCancel: nil)
//    }
    
    func updatingCurrentMessage(msg: Message, oppID opponentUID: String){
        var opponentLastMsg = msg
        
        if let opponent = self.recentOpponentMessage.first(where: { $0.uid == opponentUID })
        {
            let msgID = opponent.message.count
            opponentLastMsg.id = msgID
            opponent.message.append(opponentLastMsg)
            
        } else {
            let recentMessageID = self.recentOpponentMessage.count + 1
            guard let lastMsg = opponentLastMsg.text,
                  let timestamp = opponentLastMsg.timestamp else { return }
            let opponentRecentMessage = RecentMessage_Class(id: recentMessageID,
                                                      uid:opponentUID,
                                                      lastmsg: lastMsg,
                                                      timestamp: timestamp)
            opponentRecentMessage.message.append(opponentLastMsg)
            self.recentOpponentMessage.append(opponentRecentMessage)
            self.updatingOpponentNameAndPic(opponent: opponentRecentMessage)
        }
        self.recentOpponentMessage.sort()
    }
    
    func updatingCurrentMessage(data dictionary: [String: AnyObject], _ opponentUID: String){
        var opponentLastMsg = Message(dictionary, id: 0)
        
        if let opponent = self.recentOpponentMessage.first(where: { $0.uid == opponentUID })
        {
            let msgID = opponent.message.count
            opponentLastMsg.id = msgID
            opponent.message.append(opponentLastMsg)
            
        } else {
            let recentMessageID = self.recentOpponentMessage.count + 1
            guard let lastMsg = opponentLastMsg.text,
                  let timestamp = opponentLastMsg.timestamp else { return }
            let opponentRecentMessage = RecentMessage_Class(id: recentMessageID,
                                                      uid:opponentUID,
                                                      lastmsg: lastMsg,
                                                      timestamp: timestamp)
            opponentRecentMessage.message.append(opponentLastMsg)
            self.recentOpponentMessage.append(opponentRecentMessage)
            self.updatingOpponentNameAndPic(opponent: opponentRecentMessage)
        }
        self.recentOpponentMessage.sort()
    }
    
    func updatingOpponentNameAndPic(opponent: RecentMessage_Class){
        
        FirebaseManager.shared.fetchingUserNameAndAvatar_Combine(opponent: opponent)
            .sink { [weak self] opponent in
                if let index = self?.recentOpponentMessage.firstIndex(where: {$0.uid == opponent.uid }) {
                    self?.recentOpponentMessage[index] = opponent
                }
            }.store(in: &cancellable)


//        FirebaseManager.shared.fetchingUserNameAndAvatar(uid: opponentUID) { name, pic in
//            if let index = self.recentOpponentMessage.firstIndex(where: {$0.uid == opponentUID }) {
//                let opponent = self.recentOpponentMessage[index]
//                opponent.name = name
//                opponent.pic = pic
//                self.recentOpponentMessage[index] = opponent
//            }
            
            
//            if let opponent = self.recents.first(where: { $0.uid == opponentUID }) {
////                DispatchQueue.main.sync { not working
//                    opponent.name = name
//                    opponent.pic = pic
//
//                //self.recents.first(where: { $0.uid == opponentUID }).name = name not
// Done 20221206 the array will not update if only change the data inside one element in array
// have to update the array directly
// TODO: find out why without the code below the UI dont refresh
//                self.errorMessage = ""
//            }
        
    }
}

struct MainMessageView_LBTA: View {
    
    // MARK: - Data
    @State private var showingOptions = false
    
    @StateObject private var vm = MainMessageViewModel()
    
    @State private var newMessageScreenShowed = false
    
    @State private var navigatingToChatLogView = false
    
    @State private var currentUser: ChatUser?
    
    
    // MARK: - Func
    
    private func createChatLogViewModel_LBTA() -> ChatLogViewModel_LBTA {
        return ChatLogViewModel_LBTA(chatUser: self.currentUser)
    }
    
    private func createChatLogView_LBTA(vm: ChatLogViewModel_LBTA) -> some View {
        return ChatLogView_LBTA(chatUser: self.currentUser, vm: vm)
    }
    
    private func ondDismissLoginAndRegistration() {
        
        self.vm.isUserCurrentlyLoggedOut = false
        self.vm.fetchingCurrentUserInfo()
        self.vm.fetchCurrentMessage()
    }
    
    
    // MARK: - View
    
    var body: some View {
//        NavigationView {
//            Color.red
            VStack {
//                Text("\(vm.errorMessage)")
//                    .lineLimit(10)
//                    .background(Color.red)

                customNavBar

                messageView

                NavigationLink("", isActive: $navigatingToChatLogView){
//                    Text("uid: \(self.chatUser?.uid ?? ""), id:\(self.chatUser?.id ?? "")")
                    createChatLogView_LBTA(vm: createChatLogViewModel_LBTA())
                }
            }
            .navigationBarHidden(true)
//            .edgesIgnoringSafeArea(.all)

            .overlay(
                newMessageButton, alignment: .bottom
            )
            .onDisappear {
//                vm.userRef?.removeAllObservers()
            }
//        }
    }
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            WebImage(url: URL(string: vm.currentUser?.profilImage ?? ""))
                .resizable()
                .frame(width: 48, height: 48)
                .scaledToFill()
                .clipped()
                .cornerRadius(44)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.currentUser?.name ?? "user name")")
                    .font(.system(size: 24, weight: .bold))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            Spacer()
            Button {
                showingOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
//                    .background(Color.red)
            }
            
        }
        .padding(.top, 8)
        .padding()
        .actionSheet(isPresented: $showingOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do "),
                  buttons: [
                    .destructive(Text("Sign out"), action: {
                        vm.handlingSignOut()
                    }),
                    .cancel()
                           ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: ondDismissLoginAndRegistration) {
            LoginAndRegistration_LBTA()
            
        }
    }
    
    private var newMessageButton: some View {
        Button {
            newMessageScreenShowed.toggle()
        } label: {
            VStack {
                HStack {
                    Spacer()
                    Text("+ New Message")
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
                Spacer().frame(height: 4)
            }
            .fullScreenCover(isPresented: $newMessageScreenShowed) {
                NewMessageView_LBTA { user in
                    print(user.email)
                    self.navigatingToChatLogView.toggle()
                    self.currentUser = user
                }
            }
        }
    }
    
    private var messageView: some View {
        ScrollView {
            ForEach(vm.recentOpponentMessage) { recentMessage in
                VStack {
                    Button {
                        let uid = String(recentMessage.uid)
                        self.currentUser = .init(uid: uid, dictionary: nil)
                        self.navigatingToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.pic ))
                                .resizable()
                                .frame(width: 48, height: 48)
                                .scaledToFill()
                                .clipped()
                                .cornerRadius(44)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1))

                            VStack(alignment: .leading, spacing: 4 ) {
                                Text("\(recentMessage.name)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color(.label))
                                Text("\(recentMessage.lastmsg)")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(.darkGray))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text("\(recentMessage.timeInFormatt)")
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(Color(.label))
                    }
                    Divider()
                        .padding(.vertical, 8)


                }
                .padding(.horizontal)

            }
            .padding(.bottom, 60)
        }
    }
    
    // MARK: - Life Cycle

}

struct MainMessageView_Previews: PreviewProvider {
    static var previews: some View {
        //        Text("123")
        NavigationView {
            MainMessageView_LBTA()
        }
        //        MainMessageView_LBTA()
//            .preferredColorScheme(.dark)
    }
}



