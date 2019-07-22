//
//  AudioSampleBufferPool+CMDataBuffer.swift
//  SpectroCore-iOS
//
//  Created by Tom York on 16/07/2019.
//

import AVFoundation

extension AudioSampleBufferPool {
    
    func accept(cmBuffer: CMSampleBuffer) {
        
        guard let info = AudioSampleBufferInfo(cmBuffer: cmBuffer) else {
            return
        }
        
        sizeToFit(bufferInfo: info)
        
        // Extract data
        guard let audioBlockBuffer = CMSampleBufferGetDataBuffer(cmBuffer) else {
            return
        }
        
        for (channelIndex, buffer) in buffers.enumerated() {
            buffer.acceptChannelData(from: audioBlockBuffer, channelIndex: channelIndex, bufferInfo: info)
        }
    }
}
