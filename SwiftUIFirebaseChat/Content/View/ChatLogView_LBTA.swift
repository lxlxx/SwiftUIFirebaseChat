//
//  ChatLogView_LBTA.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 18/10/2022.
//
//https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
//
//https://stackoverflow.com/questions/69217703/swiftui-how-can-i-use-observedobject-or-environmentobject-to-store-geometryrea
//
//https://stackoverflow.com/questions/59083437/setting-view-frame-based-on-geometryreader-located-inside-that-view-in-swiftui

// Sharing data across tabs using @EnvironmentObject – Hot Prospects SwiftUI Tutorial 11/18
// https://www.youtube.com/watch?v=e2lQtUdK1uI&ab_channel=PaulHudson

// https://stackoverflow.com/questions/60511185/how-can-i-setup-firebase-to-observe-only-new-data

// Showing and hiding views – iExpense SwiftUI Tutorial 3/11
// https://www.youtube.com/watch?v=61O6IdqKZVg&ab_channel=PaulHudson

// https://stackoverflow.com/questions/72401569/show-custom-popup-view-on-top-of-view-hierarchy-swiftui

// SwiftUI 2.0 Multiple Image Viewer - Pinch to Zoom - Drag to Dismiss - SwiftUI Tutorials
// https://www.youtube.com/watch?v=XDH1KmI86b0&ab_channel=Kavsoft

// Protocol and Value Oriented Programming in UIKit Apps
// https://developer.apple.com/videos/play/wwdc2016/419/
//https://developer.apple.com/library/archive/LucidDreams/Introduction/Intro.html#//apple_ref/doc/uid/TP40017334-Intro-DontLinkElementID_2

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import Combine

struct ChatMessage {
    let fromID, toID, text: String
    
    init(data: [String: Any]) {
        self.fromID = data[GlobalString.fromID] as? String ?? ""
        self.toID = data[GlobalString.toID] as? String ?? ""
        self.text = data[GlobalString.text] as? String ?? ""
    }
}

class ChatLogViewModel_LBTA: ObservableObject {
    @Published var chatText = ""
    
    @Published var chatMessage: [Message] = []
    
    @Published var imageSelected: UIImage?
    
    private var cancellable = Set<AnyCancellable>()
    
    let chatUser: ChatUser?
    
    
    init(chatUser: ChatUser?) {
//        self.chatMessage = []
        self.chatUser = chatUser
        
        fetchingMessage()
    }
    
    deinit {
//        printLog("deinit")
    }
    
    
    // MARK: fetch message with partner func
    
    func removeAllChatMessages() {
        chatMessage.removeAll()
    }
    func fetchingMessage() {
        guard let opponentID = chatUser?.uid else { return }
        
        removeAllChatMessages()
        
//        FirebaseManager.shared.fetchingAllMessageByOpponentID(opponentID: opponentID){
//            [ weak weakSelf = self]  msg in
//            weakSelf?.appendMessage(msg)
//        }
        FirebaseManager.shared.fetchingAllMessageByOpponentID_Combine(opponentID: opponentID)
            .compactMap{ $0 }
            .flatMap { ref in
                FirebaseManager.shared.fetchingMessageContentByMsgID_Combine(ref).eraseToAnyPublisher()
            }
            .compactMap{ $0 }
            .sink { _ in
                
            } receiveValue: { [weak self] msg in
                self?.appendMessage(msg)
            }
            .store(in: &cancellable)

    }
    
    func appendMessage(_ msg: Message ) {
        var lastMsg = msg
        let messageIDCount = chatMessage.count + 1
        lastMsg.id = messageIDCount
        chatMessage.append(lastMsg)
    }
    
    func appendMessage(_ dictionary: [String: AnyObject] ) {
        let messageIDCount = chatMessage.count + 1
        chatMessage.append(Message(dictionary, id: messageIDCount))
    }
    
    // MARK: send func
    func handlingSendImageMsg() {
        guard let toID = chatUser?.uid, let imageSelected = imageSelected else { return }
        
        FirebaseManager.shared.sendImageMessage(opponentID: toID, image: imageSelected)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                default: break
                }
            } receiveValue: { result in
                if result { self.imageSelected = nil }
            }
            .store(in: &cancellable)

    }
    
    func handlingSendChatMsg() {
        guard let toID = chatUser?.uid, chatText != "" else { return }
        
//        FirebaseManager.shared.sendTextMessage(opponentID: toID, chatText: chatText) {
//            self.chatText = ""
//        }
        FirebaseManager.shared.sendTextMessage(opponentID: toID, chatText: chatText)
            .sink { completion in
                switch completion {
                case let .failure(error):
                    print(error)
                default: break
                }
            } receiveValue: { [unowned self] result in
                if result { self.chatText = "" }
            }
            .store(in: &cancellable)

    }
}


struct ChatLogView_LBTA: View {
    
    // MARK: - Data
    
    private let bottomViewID = "bottomView"
    
    @ObservedObject var vm: ChatLogViewModel_LBTA
    
    @State private var shouldShowImagePicker = false
    
    let chatUser: ChatUser?
    
    // MARK: - Func
    
    private func scrollToButtom(proxy: ScrollViewProxy) {
        proxy.scrollTo(bottomViewID, anchor: .bottom)
    }
    
    // MARK: - View
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if #available(iOS 15.0, *) {
                    messageView
                        .safeAreaInset(edge: .bottom) {
                            messageInputView
                        }
                } else {
                    messageView
                    messageInputView
                }
                
            }
            .environment(\.mainWindowSize, proxy.size)
            .onDisappear {
//                vm.chatLogRef?.removeAllObservers()
                
            }
            
        }
        
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: {
            vm.handlingSendImageMsg()
        }) {
            ImagePicker_LBTA(image: $vm.imageSelected)
        }
        
    }
    //    How to use protocol in List in SwiftUI #446
    //    This is not possible because item in List needs to conform to Identifiable
    //
    //    Protocol type 'Service' cannot conform to 'Identifiable' because only concrete types can conform to protocols
    //https://github.com/onmyway133/blog/issues/446
    
    private var messageView: some View {
        VStack {
            ScrollView {
                ScrollViewReader { value in
                    VStack {
                        ForEach(vm.chatMessage) { message in
                            ChatLogViewRow(content: message)
                        }
                        .onAppear(){
                            scrollToButtom(proxy: value)
                        }
                        
                        HStack { Spacer() }
                            .id(bottomViewID)
                    }
                    .onChange(of: vm.chatMessage.count) { _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollToButtom(proxy: value)
                        }
                    }
                }
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
            .navigationTitle("\(chatUser?.name ?? "")")
            
        }
    }
    
    private var messageInputView: some View {
        HStack(spacing: 16) {
            Button {
                self.shouldShowImagePicker.toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }
            TextField("message", text: $vm.chatText)
            Button {
                vm.handlingSendChatMsg()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(8)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
    
    
    // MARK: - Life Cycle
    
    init(chatUser: ChatUser?, vm: ChatLogViewModel_LBTA) {
        self.chatUser = chatUser
        self.vm = vm
    }
}

fileprivate struct ChatLogViewRow: View {
    // MARK: - Data
    var content: Message
    
    // MARK: - Func
    
    // MARK: - View
    
    var body: some View {
        HStack {
            if content.messageFromCurrentUser() {
                Spacer()
            }
            
            rowContentView
            
            if !content.messageFromCurrentUser() {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    var rowContentView: some View {
        switch content.type {
        case .text:
            ChatLogViewRow_Text(content: content)
        case .image:
            ChatLogViewRow_Image(content: content)
        }
    }
    
    // MARK: - Life Cycle
    init(content: Message) {
        self.content = content
    }
}

protocol Layout {
    // wwdc 419
    /// Lay out this layout and all of its contained layouts within `rect`.
    mutating func layout(in rect: CGRect)

    /// The type of the leaf content elements in this layout.
    associatedtype Content

    /// Return all of the leaf content elements contained in this layout and its descendants.
    var contents: [Content] { get }
}

//extension View: Layout {
//    Extension of protocol 'View' cannot have an inheritance clause
//    typealias Content = UIView
//
//    func layout(in rect: CGRect) {
//        self.frame = rect
//    }
//
//    var contents: [Content] {
//        return [self]
//    }
//}
protocol chatLogRowContent {
    var content: Message { get set }
}


struct ChatLogViewRow_Text: View, chatLogRowContent {
    var content: Message
    
    var body: some View {
        HStack {
            
            Text("\(content.text ?? "")")
                .foregroundColor(content.messageFromCurrentUser() ? .white : .black)
        }
        .padding()
        .background(content.messageFromCurrentUser() ? Color.blue : Color.white)
        .cornerRadius(16)
    }
}

struct ChatLogViewRow_Image: View, chatLogRowContent {
    
    // MARK: - Data
    var content: Message
    
    private let defaultPic = "IMG_0001"
    
    private var picSize: CGSize {
        if let imageWidth = content.imageWidth, let imageHeight = content.imageHeight {
            let mainWidth = mainWindowSize.width * 0.6
            let height = Double(mainWidth * (imageHeight / imageWidth))
            
            return CGSize(width: mainWidth, height: height)
        }
        return CGSize(width: 150, height: 100)
    }
    
    private var picURL: String {
        if let imageURL = content.imageURL {
            return imageURL
        } else {
            return defaultPic
        }
        
    }
    
//    private var screenSzie = UIScreen.main.bounds

    @Environment(\.mainWindowSize) var mainWindowSize
    
    @State private var fullScrennPicShowed = false
    
    // MARK: - View
    var body: some View {
        VStack {
            Button {
                self.fullScrennPicShowed.toggle()
            } label: {
                ZStack {
                    imageBackgroundColor
                    chatLogViewRowImage
                }
            }
        }
        .fullScreenCover(isPresented: $fullScrennPicShowed) {
            FullScreenView {
                WebImage(url: URL(string: picURL))
                    .resizable()
                    .scaledToFit()
                    .clipped()
            }
        }
    }
    
    var imageBackgroundColor: some View {
        Color(.init(white:0, alpha: 0.05))
            .frame(width: picSize.width, height: picSize.height)
            .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(.label), lineWidth: 2))
                .shadow(radius: 5)
    }
    
    var chatLogViewRowImage: some View {
        WebImage(url: URL(string: picURL))
            .resizable()
            .scaledToFit()
            .frame(width: picSize.width, height: picSize.height)
            .clipped()
            .cornerRadius(16)
    }
    

    
    // MARK: - Life Cycle
    init(content: Message) {
        self.content = content
    }
    
//    init(picURL: String? = nil, parentGeometry: GeometryProxy, fullScrennPic: Bool = false) {
//        self.picURL = picURL
//        self.parentGeometry = parentGeometry
//        self.fullScrennPic = fullScrennPic
//    }
}


//https://stackoverflow.com/questions/56938805/how-to-pass-one-swiftui-view-as-a-variable-to-another-view-struct
//struct ContainerView<Content: View>: View {
//    @ViewBuilder var content: Content
//
//    var body: some View {
//        content
//    }
//}

struct FullScreenView<Content: View>: View {
    
    // MARK: - Data
    @Environment(\.presentationMode) var presentationMode
    
    @ViewBuilder var contentView: Content

//    This variable provides an option to dismiss the full screen or not by clicking the content
//    some types of content may not need to dismiss, such as videos which may includes some interactions with user
    var dismissFullScreenByClickingContentView = true
    
    // MARK: - Func
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
    
    // MARK: - View
    var body: some View {
        
        VStack {
            ZStack {
                Color.alpha0_05
                    .onTapGesture {
                        dismissView()
                    }
                contentView
                    .onTapGesture {
                        if dismissFullScreenByClickingContentView {
                            dismissView()
                        }
                    }
                
            }
        }
        .edgesIgnoringSafeArea(.all)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
    // MARK: - Life Cycle
    

}

struct ChatLogView_LBTA_Previews: PreviewProvider {
    static var previews: some View {
//        GeometryReader { geo in
//            ChatLogViewRow_Image(parentGeometry: geo)
//        }
        let temp = ["name": "joel"] as [String: AnyObject]

        NavigationView {
            let chatOpponent = ChatUser(uid: "J057oK0WKLMQFWzz8G8DEvGSpP42", dictionary: temp)
            let vm = ChatLogViewModel_LBTA(chatUser: chatOpponent)
            ChatLogView_LBTA(chatUser: chatOpponent, vm: vm)
        }
            
        
    }
}




