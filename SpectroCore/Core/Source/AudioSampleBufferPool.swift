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
    
    var readInterval: Int {
        didSet {
            if oldValue != readInterval {
                emptyThePool()
            }
        }
    }
    
    var outputSampleCount: Int {
        didSet {
            if oldValue != outputSampleCount {
                emptyThePool()
            }
        }
    }
    
    init(outputSampleCount: Int, readInterval: Int) {

        self.outputSampleCount = outputSampleCount
        self.readInterval = readInterval
        buffers = []
    }
    
    func sizeToFit(bufferInfo info: AudioSampleBufferInfo) {
        
        if info.numberOfChannels != buffers.count {
            
            buffers = (0..<info.numberOfChannels).map { _ in
                
                return ChannelBuffer(
                    outputSizeInSamples: outputSampleCount,
                    readInterval: readInterval
                )
            }
        }
        
        assert(info.numberOfChannels == buffers.count)
    }
    
    private func emptyThePool() {
        buffers = []
    }
}
