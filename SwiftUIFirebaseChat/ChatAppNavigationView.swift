//
//  NavigationView.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 16/12/2021.
//
// @Environment vs @EnvironmentObject
// https://stackoverflow.com/questions/58061910/environment-vs-environmentobject

import SwiftUI
import Firebase

struct ChatAppNavigationView: View {
    @State var userStatus = UserDefaults.standard.value(forKey: GlobalString.userStatus) as? Bool ?? false
    
    var body: some View {
        VStack {
            if userStatus {
                MessageView().environmentObject(MessageObserver())
            } else {
                LoginAndRegistrationPageView()
            }
        }
        .onAppear{
            NotificationCenter.default.addObserver(forName: NSNotification.Name(GlobalString.statusChange), object: nil, queue: .main) {_ in 
                if let _ = Auth.auth().currentUser?.uid {
                    UserDefaults.standard.set(true, forKey: GlobalString.userStatus)
                    self.userStatus = true
                } else {
                    UserDefaults.standard.set(false, forKey: GlobalString.userStatus)
                    self.userStatus = false
                }
            }
        }
    }
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ChatAppNavigationView()
    }
}
