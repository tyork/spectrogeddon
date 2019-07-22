//
//  AudioSampleBuffer.swift
//  SpectroCore
//
//  Created by Tom York on 16/07/2019.
//

import Foundation

class AudioSampleBufferPool {
    
    var buffers: [ChannelBuffer]
    
    var hasOutput: Bool {
        return !buffers.isEmpty && buffers.allSatisfy { $0.hasOutput }
    }
    
    var output: [TimeSequence] {
        return buffers.compactMap { $0.outputSamples }
    }
    
    init() {
        buffers = []
    }
    
    func sizeToFit(bufferInfo info: AudioSampleBufferInfo) {
        
        if info.numberOfChannels != buffers.count {
            
            buffers = (0..<info.numberOfChannels).map { _ in
                return ChannelBuffer(outputSizeInSamples: 2048, readInterval: 1) // tODO:
            }
        }
        
        assert(info.numberOfChannels == buffers.count)
    }
}
