//
//  SettingsWrapper.swift
//  Spectrogeddon
//
//  Created by Tom York on 12/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let spectroSettingsDidUpdate = Notification.Name(rawValue: "spectroSettingsDidUpdate")
}

// TODO: fold this into settings store, eventually.
// TODO: audio settings
class SettingsWrapper {
    
    var displaySettings: DisplaySettings {
        return settingsStore.displaySettings
    }
    
    private var settingsStore: SettingsStore
    private var colorMaps: ColorMapSet
    private var sharpness: UInt
    
    init() {
        self.settingsStore = SettingsStore()
        self.colorMaps = ColorMapSet()
        self.sharpness = 1
        if settingsStore.displaySettings.colorMap == nil {
            let currentMap = colorMaps.currentColorMap()
            settingsStore.applyUpdate { settings in
                settings.colorMap = currentMap
                return settings
            }
        }
    }
    
    func nextColorMap() {
        let newMap = colorMaps.nextColorMap()
        settingsStore.applyUpdate { settings in
            settings.colorMap = newMap
            return settings
        }
        postNote()
    }
    
    func toggleFrequencyStretch() {
        settingsStore.applyUpdate { settings in
            settings.useLogFrequencyScale = !settings.useLogFrequencyScale
            return settings
        }
        postNote()
    }
    
    func nextScrollingSpeed() {
        let speeds = [ 1, 2, 4, 8 ]
        
        let speed = speeds.nextElementWrapping(after: displaySettings.scrollingSpeed, defaultingIfEmpty: 1)
        settingsStore.applyUpdate { settings in
            settings.scrollingSpeed = speed
            return settings
        }
        postNote()
    }
    
    func nextSharpness() {
        let sharpnessValues: [UInt] = [ 1, 2, 4 ]
        
        let sharpness = sharpnessValues.nextElementWrapping(after: displaySettings.sharpness, defaultingIfEmpty: 1)
        settingsStore.applyUpdate { settings in
            settings.sharpness = sharpness
            return settings
        }
        postNote()
    }
    
    private func set(displaySettings: DisplaySettings) {
        settingsStore.applyUpdate { old in
            return displaySettings
        }
    }
    
    private func postNote() {
        NotificationCenter.default.post(
            name: .spectroSettingsDidUpdate,
            object: settingsStore.displaySettings
        )
    }
}

extension Array where Element: Equatable {
    
    func nextElementWrapping(after element: Element, defaultingIfEmpty defaultElement: Element) -> Element {
        
        guard !isEmpty else {
            return defaultElement
        }
        
        let nextValue: Element
        if let currentIndex = lastIndex(of: element) {
            let nextIndex = (currentIndex + 1) % count
            nextValue = self[nextIndex]
        } else {
            nextValue = self[0]
        }
        return nextValue
    }
    
}
