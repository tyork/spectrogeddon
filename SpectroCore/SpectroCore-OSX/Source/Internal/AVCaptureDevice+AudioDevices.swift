//
//  AVCaptureDevice+AudioDevices.swift
//  SpectroCore
//
//  Created by Tom York on 14/07/2019.
//

import AVFoundation

extension AVCaptureDevice {
    
    static var audioDevices: [AVCaptureDevice] {

        return AVCaptureDevice.devices(for: .audio)
    }
}
