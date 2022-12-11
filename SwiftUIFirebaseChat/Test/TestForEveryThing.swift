//
//  Test.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 24/10/2022.
//

import SwiftUI

struct TestForEveryThing: View {
    var body: some View {
        ScrollView {
//            ScrollContentTestView()
            List {
                Text("One")
                Text("Two")
                Text("Three")
            }
            Text("1")
            if #available(iOS 16.0, *) {
                List {
                    Text("One")
                    Text("Two")
                    Text("Three")
                }
                .scrollContentBackground(.hidden)
            } else {
                // Fallback on earlier versions
                List {
                    Text("One")
                    Text("Two")
                    Text("Three")
                }
            }
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        TestForEveryThing()
    }
}


struct ScrollContentTestView: View {
    @State private var text = "Some text"
    
    var body: some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: $text)
                .frame(width: 300, height: 300)
                .scrollContentBackground(.hidden)
                .background(.indigo)
        } else {
            // Fallback on earlier versions
        }
    }
    
}
