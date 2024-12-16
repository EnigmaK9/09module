//
//  AppDelegate.swift
//  Barman
//
//  Created by Carlos Padilla on 12/12/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var drinkExterno: Drink?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // The network is started to be monitored here.
        NetworkReachability.shared.startMonitoring()
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // A configuration is selected to create the new scene.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        // Any resources specific to the discarded scenes are released here.
    }
}
