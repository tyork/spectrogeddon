//
//  AppDelegate.swift
//  Spectrogeddon
//
//  Created by Tom York on 11/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        application.isIdleTimerDisabled = true
        return true
    }
}
