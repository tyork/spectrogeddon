//
//  AudioBuffer.swift
//  SpectroCore
//
//  Created by Tom York on 14/07/2019.
//

import AVFoundation

class AudioSourceFinder {
    
    typealias Name = String
    typealias Identifier = String
 
    /// Localized name -> audio source ID pairs
    static var availableSources: [Name: Identifier] {
        let devices = AVCaptureDevice.audioDevices
        let namesAndIds = devices.map { ($0.localizedName, $0.uniqueID) }
        return [Name: Identifier](uniqueKeysWithValues: namesAndIds)
    }
}
