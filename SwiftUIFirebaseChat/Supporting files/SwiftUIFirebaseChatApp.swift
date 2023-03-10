//
//  SwiftUIFirebaseChatApp.swift
//  SwiftUIFirebaseChat
//
//  Created by yu fai on 27/11/2021.
//

//https://github.com/firebase/firebase-ios-sdk/blob/master/SwiftPackageManager.md

//2020 FirebaseCrashlytics solution
//https://stackoverflow.com/questions/60821249/ios-and-firebasecrashlytics

//source
//https://www.youtube.com/playlist?list=PLimqJDzPI-H827m9Mulmf1_kHCdOII62v
//MVVM
//option value & unwrap 
//UI reuse
//struct message reuse
//inversion of control vs dependency injection
//AOP
//firebase manager
//combine await GCD / concurrency
//ui unit test
//xcode doc
//network keep checking
//crashlytics + debug
//swift doc (java doc)

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Methods
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        return true
    }
}


@main
struct SwiftUIFirebaseChatApp: App {
    // MARK: - Properties
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // MARK: - Life Cycle
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView{
                MainMessageView_LBTA()
//                LoginAndRegistration_LBTA()
//                ChatAppNavigationView()
            }
        }
    }
}
