//
//  printLog.swift
//  FacebookMessengerCopy
//
//  Created by yu fai on 19/5/2016.
//  Copyright © 2016 YuFai. All rights reserved.
//

import Foundation

func printLog(_ message: Any..., file: String = #file, method: String = #function, line: Int = #line){
    let time = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y/MM/dd - hh:mm:ss a"
//    #if DEBUG
    print("\n\(dateFormatter.string(from: time)) :\n\((file as NSString).lastPathComponent) [\(line)], \(method): \n\(message)\n")
//    #endif
}
// Target -> Build settings -> Swift Compiler -> Custom Flags Debug + -> enter:(-D DEBUG)
