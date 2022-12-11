//
//  Message.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 1/12/2022.
//

import Foundation
import Firebase

enum MessageTypes{
    case text
    case video
    case image
}

struct Message: Identifiable {
    
    var id: Int
    
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    var text: String?
    
    init(_ dict:[String: Any], id: Int) {
        self.id = id
        fromID = dict["fromID"] as? String
        text = dict["text"] as? String
        timestamp = dict["timestamp"] as? NSNumber
        toID = dict["toID"] as? String

    }
    
    func messageFromCurrentUser() -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return fromID == uid ? true : false
    }
    
    func chatPartnerID() -> String {
        return fromID == Auth.auth().currentUser?.uid ? toID! : fromID!
    }
}

