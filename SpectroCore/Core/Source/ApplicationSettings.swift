//
//  SettingsController.swift
//  SpectroCore-iOS
//
//  Created by Tom York on 06/08/2019.
//

import Foundation

public struct ApplicationSettings {
    public var sharpness: Setting<UInt> = .init(default: 1, permitted: [1, 2, 4])
    public var scrollingSpeed: Setting<Int> = .init(default: 1, permitted: [1, 2, 4, 8])
    public var scrollingDirectionIndex: Setting<UInt> = .init(default: 0, permitted: [0, 1])
    public var useLogFrequencyScale: Setting<Bool> = .init(default: false, permitted: [false, true])
    public var colorMapName: Setting<String?>
    public var preferredAudioSourceId: Setting<AudioSourceID?>
    
    init(audioSourceProvider: AudioSourceProvider, colorMapProvider: ColorMapProvider) {

        let audioSourceIds = audioSourceProvider.availableSources.values
        let mapNames = colorMapProvider.names

        self.preferredAudioSourceId = .init(default: audioSourceIds.first, permitted: audioSourceIds.map { $0 })
        self.colorMapName = .init(default: mapNames.first, permitted: mapNames)
    }
}
