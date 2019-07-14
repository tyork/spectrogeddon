//
//  AVAudioSession+Configure.swift
//  SpectroCore
//
//  Created by Tom York on 14/07/2019.
//

import AVFoundation

extension AVCaptureSession {
 
    func prepareForUseWithAudioSession() throws {
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.mixWithOthers])
        try session.setMode(.measurement)
        try session.setActive(true, options: [])
        automaticallyConfiguresApplicationAudioSession = false
    }
}
