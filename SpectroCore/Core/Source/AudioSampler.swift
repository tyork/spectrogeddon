//
//  AudioSource.swift
//  Spectrogeddon
//
//  Created by Tom York on 16/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import AVFoundation

private let MaxBufferSize: UInt = 2048
private let ReadInterval: UInt = 1

class AudioSampler: NSObject {
    
    typealias SampleHandler = ([TimeSequence]) -> Void
    
    var sampleHandler: SampleHandler
    
    var preferredSource: AudioSourceFinder.Identifier? {
        didSet {
            try? prepareCaptureSession() // TODO:
        }
    }
    
    var bufferSizeDivider: UInt {
        didSet {
            isPendingBufferSizeChange = true
        }
    }

    private var bufferSize: UInt {
        return MaxBufferSize / bufferSizeDivider;
    }

    private var notificationQueue: DispatchQueue
    private var sampleQueue: DispatchQueue
    private var captureSession: AVCaptureSession
    private var channelBuffers: [SampleBuffer]
    private var isPendingBufferSizeChange: Bool
    
    init(preferredSource: AudioSourceFinder.Identifier?, notificationQueue: DispatchQueue) throws {
        
        self.bufferSizeDivider = 1
        self.notificationQueue = notificationQueue
        self.sampleHandler = { _ in }

        self.sampleQueue = DispatchQueue(label: "audio.samples", qos: .default)
        self.channelBuffers = []
        self.captureSession = AVCaptureSession()
        self.isPendingBufferSizeChange = false
        self.preferredSource = preferredSource
        
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
        
        try captureSession.prepareForUseWithAudioSession()
        
        captureSession.beginConfiguration()
        
        captureSession.inputs.forEach {
            captureSession.removeInput($0)
        }
        
        guard
            let preferredDevice = AVCaptureDevice(uniqueID: sourceId) ?? AVCaptureDevice.default(for: .audio) else {
            return // TODO: throw
        }
        
        let micInput = try AVCaptureDeviceInput(device: preferredDevice)
        
        guard captureSession.canAddInput(micInput) else {
            return // TODO: throw
        }
        captureSession.addInput(micInput)
        
        if captureSession.outputs.isEmpty {
            let dataOutput = AVCaptureAudioDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: sampleQueue)
            
            guard captureSession.canAddOutput(dataOutput) else {
                return // TODO: throw
            }
            
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
    }
}

extension AudioSampler: AVCaptureAudioDataOutputSampleBufferDelegate {
 
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        let numberOfSamples = CMSampleBufferGetNumSamples(sampleBuffer)
        guard numberOfSamples > 0 else {
            // No samples, no processing.
            return
        }
        
        // Configure buffers
        // TODO: very basic format decoding, really the minimum.
        // TODO: and actively wrong now, Mac OS X now happily issues 24 bit samples so need to fix this.
        guard let formatInfo = CMSampleBufferGetFormatDescription(sampleBuffer) else {
            return
        }
        var formatListSize = 0
        guard let bufferFormats = CMAudioFormatDescriptionGetFormatList(formatInfo, sizeOut: &formatListSize), formatListSize > 0 else {
            // Invalid format info.
            return
        }

        let firstFormat = bufferFormats[0]
        
        let format: SampleFormat
        if firstFormat.mASBD.mBytesPerFrame == MemoryLayout<Float>.size {
            format = .normedFloat32
        } else {
            format = .unnormedInt16
        }
        
        #if os(macOS)
            guard format == .normedFloat32 else { return }
        #endif
        
        if isPendingBufferSizeChange {
            channelBuffers = []
            isPendingBufferSizeChange = false
        }
        
        let channelsInBuffer = Int(firstFormat.mASBD.mChannelsPerFrame)
        if channelsInBuffer != channelBuffers.count {
            let buffers = (0..<channelsInBuffer).map { _ in
                SampleBuffer(capacity: bufferSize, readInterval: ReadInterval)
            }
            channelBuffers = buffers
        }
        
        // Extract data
        guard let audioBlockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
            return
        }
        let duration = CMTimeGetSeconds(CMSampleBufferGetOutputDuration(sampleBuffer)) // Duration
        let timeStamp = CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer))
        
        var activeChannel = 0
        var offset = 0
        var totalLength = 0
        var lengthAtOffset = 0

        repeat {
            var rawSamplesOrNil: UnsafeMutablePointer<Int8>? = nil
            CMBlockBufferGetDataPointer(audioBlockBuffer, atOffset: offset, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: &rawSamplesOrNil)

            guard let rawSamples = rawSamplesOrNil else {
                continue
            }
            
            channelBuffers[activeChannel].writeBytes(rawSamples, sampleCount: UInt(numberOfSamples), format: format, timeStamp: timeStamp, duration: duration)
            offset += lengthAtOffset
            activeChannel += 1

        } while offset < totalLength
    
        // Dispatch
        guard channelBuffers.allSatisfy({ $0.hasOutput }) else {
            return
        }

        let outputs: [TimeSequence] = channelBuffers.compactMap {
            $0.outputSamples
        }

        notificationQueue.async {
            self.sampleHandler(outputs)
        }
    }

}
