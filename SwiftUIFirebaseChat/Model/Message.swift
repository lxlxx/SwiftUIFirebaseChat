//
//  Message.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 1/12/2022.
//

import Foundation
import Firebase

protocol generalMessageContent {
    var id: Int { get set }
    
    var fromID: String? { get set }
    var timestamp: NSNumber? { get set }
    var toID: String? { get set }
    
    var type: MessageTypes { get set }
    
    var contentInText: String { get set }
    
    func messageFromCurrentUser() -> Bool
    
    func chatPartnerID() -> String
}

extension generalMessageContent {
    
    func messageFromCurrentUser() -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return fromID == uid ? true : false
    }
    
    func chatPartnerID() -> String {
        return fromID == Auth.auth().currentUser?.uid ? toID! : fromID!
    }
}

protocol textMessageContent {
    var text: String? { get set}
}

protocol imageMessageContent {
    var imageURL: String? { get set }
    var imageHeight: Int? { get set }
    var imageWidth: Int? { get set }
}

struct textMessage: generalMessageContent, textMessageContent {
    var id: Int
    
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    
    var type: MessageTypes = .text
    
    var contentInText: String
    
    var text: String?
    
    init(_ dict:[String: Any], id: Int) {
        self.id = id
        fromID = dict[GlobalString.fromID] as? String
        timestamp = dict[GlobalString.timestamp] as? NSNumber
        toID = dict[GlobalString.toID] as? String
        
        text = dict[GlobalString.text] as? String
        contentInText = dict[GlobalString.text] as? String ?? "text message"
    }
}

struct imageMessage: generalMessageContent, imageMessageContent {
    var id: Int
    
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    
    var type: MessageTypes = .image
    
    var contentInText: String
    
    var imageURL: String?
    var imageHeight: Int?
    var imageWidth: Int?
    
    init(_ dict:[String: Any], id: Int) {
        self.id = id
        fromID = dict[GlobalString.fromID] as? String
        timestamp = dict[GlobalString.timestamp] as? NSNumber
        toID = dict[GlobalString.toID] as? String
        
        imageURL = dict[GlobalString.message_imageURL] as? String
        imageHeight = dict[GlobalString.message_imageHeight] as? Int
        imageWidth = dict[GlobalString.message_imageWidth] as? Int
        
        contentInText = " [image] "
    }
}

func messageGenerator(dict:[String: Any], id: Int) -> generalMessageContent? {
    
    for message in dict {
        if message.0 == "text" {
            return textMessage(dict, id: id)
        } else if message.0 == "imageURL" {
            return imageMessage(dict, id: id)
        }
    }
        
    return nil
}

enum MessageTypes{
    case text
    case image
}

struct Message: Identifiable {
    
    var id: Int
    
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    
    var text: String?
    
    var imageURL: String?
    var imageHeight: Int?
    var imageWidth: Int?
    
    var type: MessageTypes {
        if let _ = imageURL {
            return .image
        }
        return .text
    }
    
    var content: String? {
        switch type {
        case .text:
            return text
        case .image:
            return "[ image ]"
        }
    }
    
    init(_ dict:[String: Any], id: Int) {
        self.id = id
        fromID = dict[GlobalString.fromID] as? String
        timestamp = dict[GlobalString.timestamp] as? NSNumber
        toID = dict[GlobalString.toID] as? String
        
        text = dict[GlobalString.text] as? String
        imageURL = dict[GlobalString.message_imageURL] as? String
        imageHeight = dict[GlobalString.message_imageHeight] as? Int
        imageWidth = dict[GlobalString.message_imageWidth] as? Int
    }
    
    
    func messageFromCurrentUser() -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return fromID == uid ? true : false
    }
    
    func chatPartnerID() -> String {
        return fromID == Auth.auth().currentUser?.uid ? toID! : fromID!
    }
}

