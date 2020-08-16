//
//  AudioSampleBufferInfo.swift
//  SpectroCore
//
//  Created by Tom York on 15/07/2019.
//

import Foundation

/// Express supported formats for sampling.
enum SampleFormat {
    case float32
    case int16
    
    init?(bitsPerSample: Int) {
        
        switch bitsPerSample {
        case 16:
            self = .int16
        case 32:
            self = .float32
        default:
            return nil
        }
    }
    
    var sizeInBytes: Int {
        switch self {
        case .float32:
            return MemoryLayout<Float32>.size
        case .int16:
            return MemoryLayout<Int16>.size
        }
    }
}

/// Describe the useful features of a sample buffer.
struct AudioSampleBufferInfo {
    
    let format: SampleFormat
    let numberOfChannels: Int
    let numberOfSamples: Int
    let timestamp: TimeInterval
    let duration: TimeInterval
    
    var sizeOfOneChannelInBytes: Int {
        return format.sizeInBytes * numberOfSamples
    }
    
    var requiredBufferSpaceInBytes: Int {
        return sizeOfOneChannelInBytes * numberOfChannels
    }
    
    init(format: SampleFormat, numberOfChannels: Int, numberOfSamples: Int, timestamp: TimeInterval, duration: TimeInterval) {

        assert(numberOfChannels > 0)
        
        self.format = format
        self.numberOfChannels = numberOfChannels
        self.numberOfSamples = numberOfSamples
        self.timestamp = timestamp
        self.duration = duration
    }
}
