//
//  AppDelegate.swift
//  iCast
//
//  Created by Brian Jiménez Moedano on 10/08/23.
//

import UIKit
import GoogleCast
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate {

    let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID
    //let kReceiverAppID = "C0868879"
    let kDebugLoggingEnabled = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().discoveryManager.startDiscovery()
        // Enable logger.
        GCKLogger.sharedInstance().delegate = self
        FirebaseApp.configure()
        return true
    }
    
    // MARK: - GCKLoggerDelegate

    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        if (kDebugLoggingEnabled) {
            print(function + " - " + message)
        }
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

