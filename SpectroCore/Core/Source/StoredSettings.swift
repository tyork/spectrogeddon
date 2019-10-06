//
//  DisplaySettings.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

struct StoredSettings: Codable {
    let sharpness: UInt
    let scrollingSpeed: Int
    let scrollingDirectionIndex: UInt
    let useLogFrequencyScale: Bool
    let colorMapName: String?
    let preferredAudioSourceId: String?
}

extension StoredSettings {
    
    init(applicationSettings settings: ApplicationSettings) {
        self.sharpness = settings.sharpness.value
        self.scrollingSpeed = settings.scrollingSpeed.value
        self.scrollingDirectionIndex = settings.scrollingDirectionIndex.value
        self.useLogFrequencyScale = settings.useLogFrequencyScale.value
        self.colorMapName = settings.colorMapName.value
        self.preferredAudioSourceId = settings.preferredAudioSourceId.value
    }
    
    func apply(to settings: inout ApplicationSettings) {
        
        settings.sharpness.set(sharpness)
        settings.scrollingSpeed.set(scrollingSpeed)
        settings.scrollingDirectionIndex.set(scrollingDirectionIndex)
        settings.useLogFrequencyScale.set(useLogFrequencyScale)
        settings.colorMapName.set(colorMapName)
        settings.preferredAudioSourceId.set(preferredAudioSourceId)
    }
}
