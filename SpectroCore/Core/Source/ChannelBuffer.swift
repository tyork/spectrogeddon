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
    private var unnormedBuffer: [Float32]
    private var circularBuffer: CircularBuffer
    
    var hasOutput: Bool {
        return circularBuffer.hasOutput
    }
    
    var outputSamples: TimeSequence? {
        return circularBuffer.outputSamples
    }
    
    init(outputSizeInSamples sampleCount: Int, readInterval: Int) {
        inputBuffer = []
        unnormedBuffer = []
        normedBuffer = []
        circularBuffer = CircularBuffer(capacity: sampleCount, readInterval: readInterval)
    }

    func updateFromInputBuffer(bufferInfo info: AudioSampleBufferInfo) {
     
        copyFromInputBuffer(givenBufferInfo: info)
        
        circularBuffer.write(samples: normedBuffer, bufferInfo: info)
    }
    
    func sizeStorageToFit(bufferInfo info: AudioSampleBufferInfo) {
        
        if inputBuffer.count != info.sizeOfOneChannelInBytes {
            inputBuffer = [UInt8](repeating: 0, count: info.sizeOfOneChannelInBytes)
        }
        
        if unnormedBuffer.count != info.numberOfSamples {
            unnormedBuffer = [Float32](repeating: 0, count: info.numberOfSamples)
        }

        if normedBuffer.count != info.numberOfSamples {
            normedBuffer = [Float32](repeating: 0, count: info.numberOfSamples)
        }
    }
    
    private func copyFromInputBuffer(givenBufferInfo info: AudioSampleBufferInfo) {
        
        switch info.format {
        case .float32:
            copy32(source: inputBuffer, target: &normedBuffer)
            
        case .int16:
            copy16(source: inputBuffer, target: &unnormedBuffer)
            var scale = 1/Float32(Int16.max)
            vDSP_vsmul(&unnormedBuffer, 1, &scale, &normedBuffer, 1, vDSP_Length(info.numberOfSamples))
        }
    }
}

private func copy32(source: [UInt8], target: inout [Float32]) {

    precondition(source.count == target.count * MemoryLayout<Float32>.size)

    target.withUnsafeMutableBytes { bytes in
        _ = source.copyBytes(to: bytes)
    }
}

private func copy16(source: [UInt8], target: inout [Float32]) {
    
    precondition(source.count == target.count * MemoryLayout<Int16>.size)

    source.withUnsafeBytes { byteBuffer in
        
        let wordBuffer = byteBuffer.bindMemory(to: Int16.self)
        if let base = wordBuffer.baseAddress {
            vDSP_vflt16(base, 1, &target, 1, vDSP_Length(target.count))
        }
    }
}
