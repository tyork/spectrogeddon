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
    
    var preferredSource: AudioSourceFinder.Identifier? {
        didSet {
            try? prepareCaptureSession() // TODO: sort out path to error reporting from here
        }
    }
    
    var bufferSizeDivider: Int {
        didSet {
            needsBufferResize = true
        }
    }

    private var bufferSize: Int {
        return MaxBufferSize / bufferSizeDivider;
    }

    private var notificationQueue: DispatchQueue
    private var sampleQueue: DispatchQueue
    private var captureSession: AVCaptureSession
    private var needsBufferResize: Bool
    private let bufferPool: AudioSampleBufferPool
    
    init(preferredSource: AudioSourceFinder.Identifier?, notificationQueue: DispatchQueue) throws {
        
        self.bufferSizeDivider = 1
        self.notificationQueue = notificationQueue
        self.sampleHandler = { _ in }

        self.sampleQueue = DispatchQueue(label: "audio.samples", qos: .default)
        self.captureSession = AVCaptureSession()
        self.needsBufferResize = false
        self.preferredSource = preferredSource
        self.bufferPool = AudioSampleBufferPool()
        
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
            dataOutput.setSampleBufferDelegate(self, queue: sampleQueue)
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

        notificationQueue.async {
            self.sampleHandler(output)
        }
    }

}
