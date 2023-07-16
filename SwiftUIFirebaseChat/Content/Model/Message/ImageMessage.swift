//
//  ImageMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 11/7/2023.
//

import Foundation


protocol ImageMessageContent {
    var imageURL: String? { get set }
    var imageHeight: Double? { get set }
    var imageWidth: Double? { get set }
}


struct ImageMessage: GeneralMessageContent, ImageMessageContent {
    var id: Int
    
    var fromID: String?
    var timestamp: NSNumber?
    var toID: String?
    
    var type: MessageTypes = .image
    
    var contentInText: String
    
    var imageURL: String?
    var imageHeight: Double?
    var imageWidth: Double?
    
    init(_ dict:[String: Any], id: Int) {
        self.id = id
        fromID = dict[GlobalString.fromID] as? String
        timestamp = dict[GlobalString.timestamp] as? NSNumber
        toID = dict[GlobalString.toID] as? String
        
        imageURL = dict[GlobalString.message_imageURL] as? String
        imageHeight = dict[GlobalString.message_imageHeight] as? Double
        imageWidth = dict[GlobalString.message_imageWidth] as? Double
        
        contentInText = GlobalString.imageInText
    }
}
