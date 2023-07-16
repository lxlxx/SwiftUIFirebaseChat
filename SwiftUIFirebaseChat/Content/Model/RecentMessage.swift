//
//  RecentMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 5/12/2022.
//


import Foundation


class RecentMessage: Identifiable, Comparable, Equatable {
    // MARK: - Data
    var id: Int
    
    var uid: String {
        didSet {

        }
    }
    
    var name: String = GlobalString.user_name
    var profileImage: String = ""
    
    var lastMessage: String
    
    var message: [any GeneralMessageContent] = [] {
        willSet {
            guard let lastMsg = newValue.last?.contentInText,
                  let ts = newValue.last?.timestamp else { return }
            lastMessage = lastMsg
            timestamp = ts
        }
    }
    
    var timestamp: NSNumber
    
    var timeInFormattedString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let timeInDate = Date(timeIntervalSince1970: TimeInterval(truncating: timestamp))
        return formatter.localizedString(for: timeInDate, relativeTo: Date())
    }
    
    // MARK: - Func
    static func <(lhs: RecentMessage, rhs: RecentMessage) -> Bool {
        return lhs.timestamp.compare(rhs.timestamp) == .orderedDescending
        
    }
    
    static func ==(lhs: RecentMessage, rhs: RecentMessage) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    // MARK: - Life Cycle
    
    init(id: Int, uid: String, lastMessage: String, timestamp: NSNumber) {
        self.id = id
        self.uid = uid
        self.lastMessage = lastMessage
        self.timestamp = timestamp
    }
}
