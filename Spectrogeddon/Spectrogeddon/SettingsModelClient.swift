//
//  SettingsModelClient.swift
//  Spectrogeddon
//
//  Created by Tom York on 09/02/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

import Foundation

@MainActor
protocol SettingsModelClient: AnyObject {
    var settingsModel: SettingsWrapper { get set }
}
