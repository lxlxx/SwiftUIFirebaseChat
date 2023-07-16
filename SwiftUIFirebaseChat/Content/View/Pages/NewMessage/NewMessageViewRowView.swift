//
//  NewMessageViewRowViewDetail.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI

struct NewMessageViewRowView: View {
    let user: ChatUser
    
    var body: some View {
        HStack(spacing: 16) {
            UserAvatarView(url: user.profileImage, size: CGSize(width: 48, height: 48))
            
            Text("\(user.name.emailReplacement())").foregroundColor(.label)
            Spacer()
        }
        .padding(.horizontal)
        
        Divider()
            .padding(.vertical, 8)
    }
    init(user: ChatUser) {
        self.user = user
    }
}

//struct NewMessageViewRowViewDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        NewMessageViewRowViewDetail()
//    }
//}
