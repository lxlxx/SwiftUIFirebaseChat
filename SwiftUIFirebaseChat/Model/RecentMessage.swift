//
//  RecentMessage.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 5/12/2022.
//

//https://stackoverflow.com/questions/41940994/closure-cannot-implicitly-capture-a-mutating-self-parameter

import Foundation

struct RecentMessage: Identifiable, Comparable, Equatable {
    // MARK: - Data
    var id: Int
    
    var uid: String {
        didSet {
//            settingNameAndPic()
        }
    }
    
    var name: String = "user name"
    var pic: String = ""
    
    var lastmsg: String
    
    var message: [Message] = []
    
    var timestamp: NSNumber
    
    var timeInFormatt: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let timeInDate = Date(timeIntervalSince1970: TimeInterval(truncating: timestamp))
        return formatter.localizedString(for: timeInDate, relativeTo: Date())
    }
    
    // MARK: - Func
    static func <(lhs: RecentMessage, rhs: RecentMessage) -> Bool {
        return lhs.timestamp.compare(rhs.timestamp) == .orderedDescending
        //        return lhs.timeInFormatt > rhs.timeInFormatt
    }
    
    static func ==(lhs: RecentMessage, rhs: RecentMessage) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    mutating func settingNameAndPic(){
        var result = self
        FirebaseManager.shared.fetchingUserNameAndAvatar(uid: uid) { name, pic in
            result.name = name
            result.pic = pic
        }
        self = result
    }
    // MARK: - Life Cycle
    init(id: Int, uid: String, lastmsg: String, timestamp: NSNumber) {
        self.id = id
        self.uid = uid
        self.lastmsg = lastmsg
        self.timestamp = timestamp
    }
    
    init(id: Int, uid: String, name: String, pic: String, lastmsg: String, timestamp: NSNumber) {
        self.id = id
        self.uid = uid
        self.lastmsg = lastmsg
        self.timestamp = timestamp
    }
}



class RecentMessage_Class: Identifiable, Comparable, Equatable {
    // MARK: - Data
    var id: Int
    
    var uid: String {
        didSet {
//            settingNameAndPic()
        }
    }
    
    var name: String = "user name"
    var pic: String = ""
    
    var lastmsg: String
    
    var message: [Message] = [] {
        willSet {
            guard let lastMsg = newValue.last?.text,
                  let ts = newValue.last?.timestamp else { return }
            lastmsg = lastMsg
            timestamp = ts
        }
    }
    
    var timestamp: NSNumber
    
    var timeInFormatt: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        let timeInDate = Date(timeIntervalSince1970: TimeInterval(truncating: timestamp))
        return formatter.localizedString(for: timeInDate, relativeTo: Date())
    }
    
    // MARK: - Func
    static func <(lhs: RecentMessage_Class, rhs: RecentMessage_Class) -> Bool {
//        return lhs.timestamp.compare(rhs.timestamp) == .orderedAscending
        return lhs.timestamp.compare(rhs.timestamp) == .orderedDescending
        //        return lhs.timeInFormatt > rhs.timeInFormatt
    }
    
    static func ==(lhs: RecentMessage_Class, rhs: RecentMessage_Class) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func settingNameAndPic(){
        
        FirebaseManager.shared.fetchingUserNameAndAvatar(uid: uid) { [weak self = self] name, pic in
            self?.name = name
            self?.pic = pic
        }
        
    }
    // MARK: - Life Cycle
    
    init(id: Int, uid: String, lastmsg: String, timestamp: NSNumber) {
        self.id = id
        self.uid = uid
        self.lastmsg = lastmsg
        self.timestamp = timestamp
    }
}
