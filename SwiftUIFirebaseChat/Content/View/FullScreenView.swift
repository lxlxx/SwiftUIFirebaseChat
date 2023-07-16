//
//  FullScreenView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import SwiftUI

struct FullScreenView<Content: View>: View {
    
    // MARK: - Data
    @Environment(\.presentationMode) private var presentationMode
    
    @ViewBuilder let contentView: Content
    
    // This property provides an option to dismiss the full screen or not by clicking the content.
    // Some types of content may not need to dismiss, such as videos that include interactions with the user.
    var dismissFullScreenOnClick: Bool = true
    
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
                        if dismissFullScreenOnClick {
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

//struct FullScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        FullScreenView()
//    }
//}
