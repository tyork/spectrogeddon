//
//  AppDelegate.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 13/07/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: MainFlowCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.isIdleTimerDisabled = true
        
        coordinator = MainFlowCoordinator(window: UIWindow(frame: UIScreen.main.bounds))
        window = coordinator?.window
        coordinator?.start()
        window?.backgroundColor = .black
        window?.makeKeyAndVisible()

        return true
    }
}

