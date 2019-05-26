//
//  SettingsStore.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

class SettingsStore {
    
    private(set) var displaySettings: DisplaySettings
    
    private let storeURL: URL
    
    init(storeURL: URL = defaultStoreURL) {
        self.storeURL = storeURL
        let stored = loadSettings(at: storeURL)
        self.displaySettings = stored ?? DisplaySettings()
    }

    func applyUpdate(_ update: (DisplaySettings) -> DisplaySettings) {
        displaySettings = update(displaySettings)
        save(settings: displaySettings, to: storeURL)
    }
}

private func loadSettings(at url: URL) -> DisplaySettings? {
    precondition(url.isFileURL)
    return NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? DisplaySettings
}

private func save(settings: DisplaySettings, to url: URL) {
    precondition(url.isFileURL)
    NSKeyedArchiver.archiveRootObject(settings, toFile: url.path)
}

private let defaultStoreURL: URL = {
    
    let storeName = "Spectrogeddon.settings"
    
    let documentsURL = try! FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    
    return documentsURL.appendingPathComponent(storeName)
}()
