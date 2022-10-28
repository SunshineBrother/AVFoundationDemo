//
//  AppDelegate.swift
//  AVFoundationDemo
//
//  Created by sunshine on 2022/10/27.
//

import UIKit
import AVFoundation
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        configAudioPlayer()
        
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



extension AppDelegate {
    // 配置音频会话
    func configAudioPlayer() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
        } catch let error {
            print("Category Error: \(error)")
        }
        
        
        do {
            try session.setActive(true)
        } catch let error {
            print("Activation Error: \(error)")
        }
        
    }
}
