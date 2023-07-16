//
//  Message.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 1/12/2022.
//

import Foundation
import Firebase

protocol GeneralMessageContent: Identifiable, Equatable, Hashable {
    var id: Int { get set }
    
    var fromID: String? { get set }
    var timestamp: NSNumber? { get set }
    var toID: String? { get set }
    
    var type: MessageTypes { get set }
    
    var contentInText: String { get set }
    
    func isMessageFromCurrentUser() -> Bool
    
    func chatPartnerID() -> String
}

extension GeneralMessageContent {
    
    func isMessageFromCurrentUser() -> Bool {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return false }
        return fromID == currentUserID ? true : false
    }
    
    func chatPartnerID() -> String {
        guard let toID = toID, let fromID = fromID else { return "" }
        return isMessageFromCurrentUser() ? toID : fromID
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AnyMessageContent: Identifiable {
    var id: Int
    var message: any GeneralMessageContent
    
    init(_ message: any GeneralMessageContent) {
        self.id = message.id
        self.message = message
    }
}


func generateMessage(dict:[String: Any], id: Int) -> (any GeneralMessageContent)? {
    
    for (key, _) in dict {
        switch key {
        case GlobalString.text:
            return TextMessage(dict, id: id)
        case GlobalString.message_imageURL:
            return ImageMessage(dict, id: id)
        default:
            break
        }
    }
    
    return nil
}

