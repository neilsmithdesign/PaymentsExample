//
//  SceneDelegate.swift
//  PaymentsExample
//
//  Created by Neil Smith on 28/11/2019.
//  Copyright © 2019 Neil Smith. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var controller: ExampleStoreController!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        controller = ExampleStoreController(window: window!)
    }

}

