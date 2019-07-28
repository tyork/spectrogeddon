//
//  ChannelBuffer.swift
//  SpectroCore-iOS
//
//  Created by Tom York on 22/07/2019.
//

import Foundation
import Accelerate

class ChannelBuffer {
    
    var inputBuffer: [UInt8]
    private var normedBuffer: [Float32]
    private var circularBuffer: CircularBuffer
    
    var hasOutput: Bool {
        return circularBuffer.hasOutput
    }
    
    var outputSamples: TimeSequence? {
        return circularBuffer.outputSamples
    }
    
    init(outputSizeInSamples sampleCount: Int, readInterval: Int) {
        inputBuffer = []
        normedBuffer = []
        circularBuffer = CircularBuffer(capacity: sampleCount, readInterval: readInterval)
    }

    func updateFromInputBuffer(bufferInfo info: AudioSampleBufferInfo) {
     
        copy(source: inputBuffer, target: &normedBuffer, bufferInfo: info)
        
        circularBuffer.write(samples: normedBuffer, bufferInfo: info)
    }
    
    func sizeStorageToFit(bufferInfo info: AudioSampleBufferInfo) {
        
        if inputBuffer.count != info.sizeOfOneChannelInBytes {
            inputBuffer = [UInt8](repeating: 0, count: info.sizeOfOneChannelInBytes)
        }
        
        if normedBuffer.count != info.numberOfSamples {
            normedBuffer = [Float32](repeating: 0, count: info.numberOfSamples)
        }
    }
    
    private func copy(source: [UInt8], target: inout [Float32], bufferInfo info: AudioSampleBufferInfo) {
        
        switch info.format {
        case .float32:
            target.withUnsafeMutableBytes { bytes in
                _ = source.copyBytes(to: bytes)
            }
            
        case .int16:
            source.withUnsafeBytes { byteBuffer in
                
                let wordBuffer = byteBuffer.bindMemory(to: Int16.self)
                if let base = wordBuffer.baseAddress {
                    vDSP_vflt16(base, 1, &target, 1, vDSP_Length(info.numberOfSamples))
                }
            }
        }
    }
}
