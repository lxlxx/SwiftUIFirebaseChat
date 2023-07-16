//
//  ChatLogRowView_Image.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 8/5/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatLogRowImageView: View, ChatLogRowContent {
    
    // MARK: - Data
    var content: any GeneralMessageContent
    
    private let defaultPic = GlobalString.defaultImage
    
    private var picSize: CGSize {
        if let content = content as? ImageMessage {
            if let imageWidth = content.imageWidth, let imageHeight = content.imageHeight {
                let mainWidth = mainWindowSize.width * 0.6
                let height = Double(mainWidth * (imageHeight / imageWidth))
                
                return CGSize(width: mainWidth, height: height)
            }
            
        }
        return CGSize(width: 150, height: 100)
    }
    
    private var picURL: String {
        if let content = content as? ImageMessage {
            if let imageURL = content.imageURL {
                return imageURL
            }
        }
        return defaultPic
        
    }
    

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
    init(content: any GeneralMessageContent) {
        self.content = content
    }
    
}






//struct ChatLogRowView_Image_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatLogRowView_Image()
//    }
//}
