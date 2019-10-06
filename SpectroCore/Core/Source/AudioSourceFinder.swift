//
//  AudioBuffer.swift
//  SpectroCore
//
//  Created by Tom York on 14/07/2019.
//

import AVFoundation

class AudioSourceFinder: AudioSourceProvider {
    
    /// Localized name -> audio source ID pairs
    var availableSources: [AudioSourceName: AudioSourceID] {
        let devices = AVCaptureDevice.audioDevices
        let namesAndIds = devices.map { ($0.localizedName, $0.uniqueID) }
        return [AudioSourceName: AudioSourceID](uniqueKeysWithValues: namesAndIds)
    }
}
