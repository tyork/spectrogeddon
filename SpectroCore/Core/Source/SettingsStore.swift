//
//  SettingsStore.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

public class SettingsStore {
    
    public var settings: ApplicationSettings {
        didSet {
            save(settings: StoredSettings(applicationSettings: settings), to: storeURL)
        }
    }
    
    public func update(_ updater: (ApplicationSettings) -> ApplicationSettings) {
        settings = updater(settings)
    }

    public let audioSourceProvider: AudioSourceProvider
    public let colorMapProvider: ColorMapProvider
    private let storeURL: URL
    
    init(storeURL: URL, colorMapProvider: ColorMapProvider, audioSourceProvider: AudioSourceProvider) {
        
        self.storeURL = storeURL
        self.colorMapProvider = colorMapProvider
        self.audioSourceProvider = audioSourceProvider
        self.settings = ApplicationSettings(audioSourceProvider: audioSourceProvider, colorMapProvider: colorMapProvider)
        if let stored = loadSettings(at: storeURL) {
            stored.apply(to: &settings)
        }
    }
}

public extension SettingsStore {

    convenience init() {
        
        self.init(
            storeURL: defaultStoreURL,
            colorMapProvider: ColorMapStore(),
            audioSourceProvider: AudioSourceFinder()
        )
    }
    
}
//
//private extension ApplicationSettings {
//
//    init(stored settings: StoredSettings) {
//        self.sharpness = settings.sharpness
//        self.scrollingSpeed = settings.scrollingSpeed
//        self.scrollingDirectionIndex = settings.scrollingDirectionIndex
//        self.useLogFrequencyScale = settings.useLogFrequencyScale
//        self.colorMapName = settings.colorMapName ?? "" // todo
//        self.preferredAudioSourceId = settings.preferredAudioSourceId ?? "" // todo
//    }
//
//    var storable: StoredSettings {
//
//        return StoredSettings(
//            sharpness: sharpness,
//            scrollingSpeed: scrollingSpeed,
//            scrollingDirectionIndex: scrollingDirectionIndex,
//            useLogFrequencyScale: useLogFrequencyScale,
//            colorMapName: colorMapName,
//            preferredAudioSourceId: preferredAudioSourceId
//        )
//    }
//}

private func loadSettings(at url: URL) -> StoredSettings? {
    
    do {
        let data = try Data(contentsOf: url)
        let object = try JSONDecoder().decode(StoredSettings.self, from: data)
        return object
    } catch {
        print("Failed to load settings from \(url.path): \(error)")
        return nil
    }
}

private func save(settings: StoredSettings, to url: URL) {
    
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

//private extension DisplaySettings {
//
//    static func withDefaultsFromProviders(colorMaps: ColorMapProvider, audioSources: AudioSourceProvider) -> DisplaySettings {
//        var settings = DisplaySettings()
//
//        if settings.colorMapName == nil {
//            settings.colorMapName = colorMaps.names.first
//        }
//
//        if settings.preferredAudioSourceId == nil {
//            settings.preferredAudioSourceId = audioSources.availableSources.values.first
//        }
//
//        return settings
//    }
//}
