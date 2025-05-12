//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Денис Максимов on 12.05.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = WeatherViewController()
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

