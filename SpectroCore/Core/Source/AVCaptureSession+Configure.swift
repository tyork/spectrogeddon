//
//  AVCaptureSession+Configure.swift
//  SpectroCore
//
//  Created by Tom York on 14/07/2019.
//

import AVFoundation

extension AVCaptureSession {
    
    func configureForAudioCapture(preferredSource sourceId: AudioSourceID, outputProvider: () -> AVCaptureOutput) throws {
        
        try prepareForUseWithAudioSession()
        
        beginConfiguration()
        
        inputs.forEach {
            removeInput($0)
        }
        
        guard let preferredDevice = AVCaptureDevice(uniqueID: sourceId) ?? AVCaptureDevice.default(for: .audio) else {
            return // TODO: throw
        }
        
        let micInput = try AVCaptureDeviceInput(device: preferredDevice)
        
        guard canAddInput(micInput) else {
            return // TODO: throw
        }
        addInput(micInput)
        
        if outputs.isEmpty {
            let output = outputProvider()
            
            guard canAddOutput(output) else {
                return // TODO: throw
            }
            
            addOutput(output)
        }
        
        commitConfiguration()

    }
}
