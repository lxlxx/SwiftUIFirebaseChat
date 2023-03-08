//
//  UserAvatarView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 8/3/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserAvatarView: View {
    var url: String
    var size: CGSize = CGSize(width: 48, height: 48)
    
    var tapEnabled: Bool = true
    
    @State var fullScreenIsPresented: Bool = false
    
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .frame(width: size.width, height: size.height)
            .scaledToFill()
            .clipped()
            .cornerRadius(44)
            .overlay(RoundedRectangle(cornerRadius: 44)
                .stroke(Color(.label), lineWidth: 1))
            .shadow(radius: 5)
            .onTapGesture {
                if tapEnabled {
                    fullScreenIsPresented = true
                }
            }
            .fullScreenCover(isPresented: $fullScreenIsPresented) {
                FullScreenView {
                    WebImage(url: URL(string: url))
                        .resizable()
                        .scaledToFit()
                        .clipped()
                }
            }
    }
}


struct UserAvatarView_Previews: PreviewProvider {
    static var previews: some View {
        let url = "https://yt3.ggpht.com/P-EfSx-9Q-MSQCHVv7Dp9Cg8sV3LbLfc-a06hSWGcZ1n2q77nVUJqn51vBUhvbj_qIG73W66Ow=s88-c-k-c0x00ffffff-no-rj"
        let size = CGSize(width: 300, height: 300)
        UserAvatarView(url: url, size: size)
    }
}
