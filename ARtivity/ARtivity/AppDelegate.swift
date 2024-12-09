//
//  AppDelegate.swift
//  ARtivity
//
//  Created by Сергей Киселев on 28.11.2023.
//

import UIKit
import Firebase
//import YandexMapsMobile

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
//        
//        YMKMapKit.setApiKey("d1266444-1b01-4f7c-b574-283d02a68af5")
//        YMKMapKit.setLocale("ru_RU")
//        YMKMapKit.sharedInstance()
//        let authListener = Auth.auth().addStateDidChangeListener { _, user in
//
//            if user != nil {
//
//                print("user!.uid: \(user!.uid)")
//                UserService.observeUserProfile(user!.uid) { userProfile in
//                    UserService.currentUserProfile = userProfile
//                }
//                //
//                UserDefaults.standard.set(true, forKey: "isLogin")
//            } else {
//
//                UserService.currentUserProfile = nil
//
//                UserDefaults.standard.set(false, forKey: "isLogin")
//            }
//        }
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

