//
//  AppDelegate.swift
//  RandaomNumberPair_01
//
//  Created by Naoya on 2020/10/18.
//  Copyright © 2020 Kaede. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

import AppTrackingTransparency
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
//    var alertController : UIAlertController!
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        requestIDFA()
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-8819499017949234~1081587155")
//        GADMobileAds.sharedInstance().start { (status) in
//            // 初期化が完了(or タイムアウト)
//            debugPrint("AdMob Initialization Completed")
//            for (k,v) in status.adapterStatusesByClassName {
//                debugPrint("\(k) >> \(v.state.rawValue == 1 ? "Ready" : "NotReady")")
//            }
//        }
        
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
    
    //Tracking
    func requestIDFA() {
        if #available(iOS 15, *) {
                // 1秒だけ遅らせる
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                        // Tracking authorization completed. Start loading ads here.
                        // loadAd()
                    })
                }
        } else {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                // Tracking authorization completed. Start loading ads here.
                // loadAd()
            })
        }
    }
}

