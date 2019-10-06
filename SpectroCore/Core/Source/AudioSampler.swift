//
//  AudioSource.swift
//  Spectrogeddon
//
//  Created by Tom York on 16/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import AVFoundation

private let MaxBufferSize: Int = 2048
private let ReadInterval: Int = 1

class AudioSampler: NSObject {
    
    typealias SampleHandler = ([TimeSequence]) -> Void
    
    var sampleHandler: SampleHandler
    
    var preferredSource: AudioSourceID? {
        didSet {
            try? prepareCaptureSession() // TODO: sort out path to error reporting from here
        }
    }
    
    var bufferSizeDivider: Int {
        set {
            bufferPool.readInterval = newValue
        }
        get {
            return bufferPool.readInterval
        }
    }

    private var captureQueue: DispatchQueue
    private let captureSession: AVCaptureSession
    private let bufferPool: AudioSampleBufferPool
    private var outputQueue: DispatchQueue

    init(preferredSource: AudioSourceID?, notificationQueue: DispatchQueue) throws {
        
        self.outputQueue = notificationQueue
        self.sampleHandler = { _ in }

        self.captureQueue = DispatchQueue(label: "audio.samples", qos: .default)
        self.captureSession = AVCaptureSession()
        self.preferredSource = preferredSource
        self.bufferPool = AudioSampleBufferPool(outputSampleCount: MaxBufferSize, readInterval: ReadInterval)
        
        super.init()
        
        try prepareCaptureSession()
    }
    
    func startCapturing() {
        captureSession.startRunning()
    }
    
    func stopCapturing() {
        captureSession.stopRunning()
    }
    
    private func prepareCaptureSession() throws {
        
        guard let sourceId = preferredSource else {
            return
        }
        
        try captureSession.configureForAudioCapture(preferredSource: sourceId) { [weak self] in
            let dataOutput = AVCaptureAudioDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: captureQueue)
            return dataOutput
        }
    }
}

extension AudioSampler: AVCaptureAudioDataOutputSampleBufferDelegate {
 
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        bufferPool.accept(cmBuffer: sampleBuffer)
        
        // Dispatch
        guard bufferPool.hasOutput else {
            return
        }

        let output = bufferPool.output

        outputQueue.async {
            self.sampleHandler(output)
        }
    }

}
