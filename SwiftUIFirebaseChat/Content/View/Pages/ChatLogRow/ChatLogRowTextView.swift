//
//  ChatLogRowView_Text.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI

struct ChatLogRowTextView: View, ChatLogRowContent {
    
    var content: any GeneralMessageContent
    
    var body: some View {
        HStack {
            if let textMessage = content as? TextMessage {
                Text("\(textMessage.text ?? "")")
                    .foregroundColor(textMessage.isMessageFromCurrentUser() ? .white : .black)
            }
        }
        .padding()
        .background(content.isMessageFromCurrentUser() ? Color.blue : Color.white)
        .cornerRadius(16)
    }
}

//struct ChatLogRowView_Text_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatLogRowView_Text()
//    }
//}
