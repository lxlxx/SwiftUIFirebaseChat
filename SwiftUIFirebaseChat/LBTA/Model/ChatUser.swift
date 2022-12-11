//
//  ChatUser.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 17/10/2022.
//

import Foundation

struct ChatUser:Identifiable {
    
    var id: String { uid }
    
    let uid, email, profilImage, name: String
    
    init(uid: String, dictionary: [String: AnyObject]?) {
        
        self.uid = uid
        self.email = dictionary?[GlobalString.email] as? String ?? ""
        self.name = dictionary?[GlobalString.DB_user_userName] as? String ?? ""
        
        if let pic = dictionary?[GlobalString.DB_profilepics] as? String {
            self.profilImage = pic
        } else if let pic = dictionary?[GlobalString.DB_user_profileImageUrl] as? String {
            self.profilImage = pic
        } else {
            self.profilImage = ""
        }
         
        
//        DB_user_profileImageUrl
    }
}
