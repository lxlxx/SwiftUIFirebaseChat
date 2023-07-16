//
//  TextMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import Foundation


protocol TextMessageContent {
    var text: String? { get set}
}


struct TextMessage: GeneralMessageContent, TextMessageContent {
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
        contentInText = dict[GlobalString.text] as? String ?? GlobalString.textMessageDefault
    }
}
