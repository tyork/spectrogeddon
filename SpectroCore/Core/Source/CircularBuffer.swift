//
//  SampleBuffer.swift
//  Spectrogeddon
//
//  Created by Tom York on 17/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import Accelerate

/// Stores raw samples so as to retain the newest ones when overfilled.
/// Allows easy retrieval of samples as a time sequence.
class CircularBuffer {

    var hasOutput: Bool {
        return availableSpace >= capacity / readInterval
    }
    
    var outputSamples: TimeSequence? {
        guard hasOutput else {
            return nil
        }

        // Extract the (potentially wrapped) data from the circular buffer.
        let range: Range<Int> = Int(readerIndex)..<sampleBuffer.count
        var sequence = TimeSequence(timeStamp: timeStamp, duration: duration, values: Array(sampleBuffer[range]))
        
        if readerIndex > 0 {
            // If we had to read from anywhere but zero, then this buffer wrapped and must be extracted in two parts.
            let secondRange = 0..<Int(readerIndex)
            sequence.values.append(contentsOf: sampleBuffer[secondRange])
        }
        
        timeStamp = 0.0
        readerIndex = (readerIndex + capacity / readInterval) % capacity
        availableSpace = availableSpace - capacity/readInterval
        return sequence;
    }
    
    private var capacity: Int {
        return sampleBuffer.count
    }

    private let readInterval: Int
    
    private var writerIndex: Int
    private var readerIndex: Int
    private var availableSpace: Int
    private var sampleBuffer: [Float32]
    private var timeStamp: TimeInterval
    private var duration: TimeInterval

    init(capacity: Int, readInterval: Int) {
        precondition(capacity > 0)
        precondition(readInterval > 0)
        self.readInterval = readInterval
        self.sampleBuffer = .init(repeating: 0, count: capacity)
        self.writerIndex = 0
        self.readerIndex = 0
        self.availableSpace = capacity
        self.timeStamp = 0
        self.duration = 0
    }
    
    func write(samples input: [Float32], bufferInfo info: AudioSampleBufferInfo) {
    
        let sourceRange: Range<Int>
        if info.numberOfSamples > capacity {
            // Too many samples for buffer, drop some
            let lastSamplesOffset = info.numberOfSamples - capacity
            sourceRange = lastSamplesOffset..<info.numberOfSamples
        } else {
            sourceRange = 0..<info.numberOfSamples
        }
        assert(sourceRange.count <= capacity)
        
        // We need to store our new samples by wrapping them into the circular buffer.

        let headroom = capacity - writerIndex
        input.copy(range: sourceRange.startIndex..<min(headroom, sourceRange.endIndex), to: &sampleBuffer, at: writerIndex)
        if sourceRange.count > headroom {
            input.copy(range: headroom..<sourceRange.endIndex, to: &sampleBuffer, at: 0)
        }
        
    
        //memcpy(&sampleBuffer + Int(writerIndex), samplesToProcess, Int(headroom) * MemoryLayout<Float32>.size)
//        if countToProcess > headroom {
            
//            memcpy(&sampleBuffer, samplesToProcess + Int(headroom), Int((capacity - headroom))*MemoryLayout<Float32>.size)
//        }
    
        // Increment the writer index to show where to store next.
        writerIndex += sourceRange.count
        if writerIndex >= capacity {
            // We've filled the buffer and must wrap around.
            writerIndex = writerIndex % capacity
            readerIndex = writerIndex // TODO:
        }
        availableSpace += sourceRange.count
    
        // If we don't have a timestamp, use this one.
        if timeStamp == 0.0 {
            timeStamp = info.timestamp
        }
        duration = info.timestamp + info.duration - timeStamp
    }
}

extension Array where Element == Float32 {

    func copy(range: Range<Int>, to target: inout [Float32], at offsetInTarget: Int) {

        precondition(range.count <= count)
        precondition(range.count <= (target.count - offsetInTarget))
        
        target.replaceSubrange(offsetInTarget..<(offsetInTarget+range.count), with: self[range])
        
//        let elementSize = MemoryLayout<Float32>.size

//        withUnsafeBufferPointer { sourceBuffer in
//
//            target.withUnsafeMutableBytes { targetPointer in
//
//                targetPointer.
//
//                sourceBuffer.copyBytes(to: target, from: 0..<(countToCopy*elementSize))
//
//            }
//
//        }


    }

}
