//
//  SettingsStore.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

public class SettingsStore {
    
    public var displaySettings: DisplaySettings {
        didSet {
            save(settings: displaySettings, to: storeURL)
        }
    }
    
    private let storeURL: URL
    
    public convenience init() {
        self.init(storeURL: defaultStoreURL)
    }
    
    init(storeURL: URL) {
        self.storeURL = storeURL
        let stored = loadSettings(at: storeURL)
        self.displaySettings = stored ?? DisplaySettings()
    }
}

private func loadSettings(at url: URL) -> DisplaySettings? {
    
    do {
        let data = try Data(contentsOf: url)
        let object = try JSONDecoder().decode(DisplaySettings.self, from: data)
        return object
    } catch {
        print("Failed to load settings from \(url.path): \(error)")
        return nil
    }
}

private func save(settings: DisplaySettings, to url: URL) {
    
    do {
        let data = try JSONEncoder().encode(settings)
        try data.write(to: url)
    } catch {
        print("Failed to save settings for \(url.path)")
    }
}

private let defaultStoreURL: URL = {
    
    let documentsURL = try! FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    return documentsURL.appendingPathComponent("Spectrogeddon.json")
}()
