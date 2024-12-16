//
//  SceneDelegate.swift
//  Barman
//
//  Created by Carlos Padilla on december 13, 2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        // The UIWindow `window` is optionally configured and attached to the UIWindowScene `scene`.
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // This method is called after the scene has been released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // This method is called when the scene has moved from an inactive state to an active state.
        print ("Barman became active")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // This method is called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // This method is called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // This method is called as the scene transitions from the foreground to the background.
        print ("Barman entered background")
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // This method is called when a custom URL scheme is opened.
        if let laURL = URLContexts.first?.url {
            let urlComponents = URLComponents(url: laURL, resolvingAgainstBaseURL: false)
            if let parameters = urlComponents?.queryItems {
                var params:[String:String] = [:]
                for item in parameters {
                    params[item.name] = item.value
                }
                let d = Drink(
                    name: params["name"] ?? "",
                    img: params["img"] ?? "",
                    ingredients: params["ingredients"] ?? "",
                    directions: params["directions"] ?? ""
                )
                let ad = UIApplication.shared.delegate as! AppDelegate
                ad.drinkExterno = d
                NotificationCenter.default.post(
                    name: NSNotification.Name(rawValue: "NUEVO_DRINK"),
                    object: nil
                )
            }
        }
    }
}
