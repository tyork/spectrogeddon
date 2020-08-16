//
//  AudioSampleBuffer+CMSampleBuffer.swift
//  SpectroCore
//
//  Created by Tom York on 15/07/2019.
//

import Foundation
import AVFoundation

extension AudioSampleBufferInfo {
    
    init?(cmBuffer: CMSampleBuffer) {
        
        let numberOfSamples = CMSampleBufferGetNumSamples(cmBuffer)
        guard numberOfSamples > 0 else {
            // No samples, no processing.
            return nil
        }
        
        guard let streamDescription = cmBuffer.bestAcceptableStream else {
            // No stream format we can support
            return nil
        }
        
        guard let sampleFormat = SampleFormat(bitsPerSample: Int(streamDescription.mBitsPerChannel)) else {
            // No sample format we can support
            return nil
        }
        
        let numberOfChannels = streamDescription.mChannelsPerFrame
        let bufferTimeStamp = CMTimeGetSeconds(CMSampleBufferGetOutputPresentationTimeStamp(cmBuffer))
        let bufferDuration = CMTimeGetSeconds(CMSampleBufferGetOutputDuration(cmBuffer))

        self.init(
            format: sampleFormat,
            numberOfChannels: Int(numberOfChannels),
            numberOfSamples: Int(numberOfSamples),
            timestamp: bufferTimeStamp,
            duration: bufferDuration
        )
    }
    
}

private extension CMSampleBuffer {
    
    var bestAcceptableStream: AudioStreamBasicDescription? {
        
        guard let formatInfo = CMSampleBufferGetFormatDescription(self) else {
            return nil
        }
        
        var formatListSize = 0
        guard let bufferFormats = CMAudioFormatDescriptionGetFormatList(formatInfo, sizeOut: &formatListSize), formatListSize > 0 else {
            return nil
        }
        
        // Formats are ordered with the richest first. Return the richest compatible stream.
        
        let descriptions: [AudioStreamBasicDescription] = (0..<formatListSize).map { index in
            return bufferFormats[0].mASBD
        }
        
        return descriptions.first { format in
            
            // We can't handle compressed formats or variable packet sizes.
            return format.mFramesPerPacket == 1
                && format.mBytesPerPacket != 0
                && format.mBytesPerFrame != 0
        }
    }
}
