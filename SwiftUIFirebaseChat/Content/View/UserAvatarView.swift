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
    
    @State private var isFullScreenPresented: Bool = false
    
    var body: some View {
        WebImage(url: URL(string: url))
            .resizable()
            .frame(width: size.width, height: size.height)
            .scaledToFill()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.primary, lineWidth: 1))
            .shadow(radius: 5)
            .onTapGesture {
                if tapEnabled {
                    isFullScreenPresented = true
                }
            }
            .fullScreenCover(isPresented: $isFullScreenPresented) {
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
        let url = GlobalString.dummyAvatar
        let size = CGSize(width: 300, height: 300)
        UserAvatarView(url: url, size: size)
    }
}
