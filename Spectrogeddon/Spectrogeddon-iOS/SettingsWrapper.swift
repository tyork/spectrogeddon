//
//  SettingsWrapper.swift
//  Spectrogeddon
//
//  Created by Tom York on 12/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import SpectroCoreiOS

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
    private var colorMapStore: ColorMapStore
    private var sharpness: UInt
    
    init() {
        self.settingsStore = SettingsStore()
        self.colorMapStore = ColorMapStore()
        self.sharpness = 1
        if settingsStore.displaySettings.colorMap == nil {
            settingsStore.displaySettings.colorMap = colorMapStore.currentMap
        }
    }
    
    func nextColorMap() {
        settingsStore.displaySettings.colorMap = colorMapStore.nextMap()
        postNote()
    }
    
    func toggleFrequencyStretch() {
        settingsStore.displaySettings.useLogFrequencyScale = !settingsStore.displaySettings.useLogFrequencyScale
        postNote()
    }
    
    func nextScrollingSpeed() {
        let speeds = [ 1, 2, 4, 8 ]
        let speed = speeds.nextElementWrapping(after: displaySettings.scrollingSpeed, defaultingIfEmpty: 1)
        settingsStore.displaySettings.scrollingSpeed = speed
        postNote()
    }
    
    func nextSharpness() {
        let sharpnessValues: [UInt] = [ 1, 2, 4 ]
        let sharpness = sharpnessValues.nextElementWrapping(after: displaySettings.sharpness, defaultingIfEmpty: 1)
        settingsStore.displaySettings.sharpness = sharpness
        postNote()
    }
    
    private func set(displaySettings: DisplaySettings) {
        settingsStore.displaySettings = displaySettings
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
