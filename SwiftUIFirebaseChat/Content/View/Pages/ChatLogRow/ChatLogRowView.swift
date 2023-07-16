//
//  ChatLogRowView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 8/5/2023.
//

import SwiftUI

struct ChatLogRowView: View {
    // MARK: - Data
    var content: any GeneralMessageContent
    
    // MARK: - Func
    
    // MARK: - View
    
    var body: some View {
        HStack {
            if content.isMessageFromCurrentUser() {
                Spacer()
            }
            
            rowContentView
            
            if !content.isMessageFromCurrentUser() {
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
            ChatLogRowTextView(content: content)
        case .image:
            ChatLogRowImageView(content: content)
        }
    }
    
    // MARK: - Life Cycle
    init(content: any GeneralMessageContent) {
        self.content = content
    }
}

protocol ChatLogRowContent {
    var content: any GeneralMessageContent { get set }
}





//struct ChatLogRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatLogRowView()
//    }
//}
