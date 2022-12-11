//
//  ChatLogViewGeoInfo.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 19/11/2022.
//

import Foundation
import SwiftUI

@MainActor class ChatLogViewGeoInfo: ObservableObject {
    @Published var geoInfo: GeometryProxy?
    
    init(geoInfo: GeometryProxy? = nil) {
        self.geoInfo = geoInfo
    }
}
