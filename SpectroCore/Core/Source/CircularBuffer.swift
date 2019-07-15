//
//  SampleBuffer.swift
//  Spectrogeddon
//
//  Created by Tom York on 17/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import Accelerate

enum SampleFormat {
    case normedFloat32
    case unnormedInt16
}

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
    
    private var capacity: UInt {
        return UInt(sampleBuffer.count)
    }

    private let readInterval: UInt
    
    private var writerIndex: UInt
    private var readerIndex: UInt
    private var availableSpace: UInt
    private var normalizationBuffer: [Float32]
    private var sampleBuffer: [Float32]
    private var timeStamp: TimeInterval
    private var duration: TimeInterval

    init(capacity: UInt, readInterval: UInt) {
        precondition(capacity > 0)
        precondition(readInterval > 0)
        self.readInterval = readInterval
        self.sampleBuffer = .init(repeating: 0.0, count: Int(capacity))
        self.normalizationBuffer = .init(repeating: 0.0, count: Int(capacity))
        self.writerIndex = 0
        self.readerIndex = 0
        self.availableSpace = capacity
        self.timeStamp = 0
        self.duration = 0
    }
    
    func writeBytes(_ bytes: UnsafePointer<Int8>, sampleCount: UInt, format: SampleFormat, timeStamp: TimeInterval, duration: TimeInterval) {

        switch format {
        case .normedFloat32:
            bytes.withMemoryRebound(to: Float32.self, capacity: Int(sampleCount)) {
                writeSamples($0, count: sampleCount, timeStamp: timeStamp, duration: duration)
            }
            
        case .unnormedInt16:
            bytes.withMemoryRebound(to: Int16.self, capacity: Int(sampleCount)) {
                writeSamples($0, count: sampleCount, timeStamp: timeStamp, duration: duration)
            }
        }
    }
    
    func writeSamples(_ samples: UnsafePointer<Float32>, count: UInt, timeStamp: TimeInterval, duration: TimeInterval) {
        // Drop samples if necessary
        
        let samplesToProcess: UnsafePointer<Float32>
        let countToProcess: UInt
        
        if count > capacity {
            let lastSamplesOffset = count - capacity
            samplesToProcess = samples + Int(lastSamplesOffset)
            countToProcess = capacity
        } else {
            samplesToProcess = samples
            countToProcess = count
        }

        // We need to store our new samples by wrapping them into the circular buffer.
        precondition(countToProcess <= capacity)
        let headroom = capacity - writerIndex
        memcpy(&sampleBuffer + Int(writerIndex), samplesToProcess, Int(headroom) * MemoryLayout<Float32>.size)
        if countToProcess > headroom {
            memcpy(&sampleBuffer, samplesToProcess + Int(headroom), Int((capacity - headroom))*MemoryLayout<Float32>.size)
        }
        
        // Increment the writer index to show where to store next.
        writerIndex += countToProcess
        if writerIndex >= capacity {
            // We've filled the buffer and must wrap around.
            writerIndex = writerIndex % capacity
            readerIndex = writerIndex // TODO:
        }
        availableSpace += countToProcess
        
        // If we don't have a timestamp, use this one.
        if self.timeStamp == 0.0 {
            self.timeStamp = timeStamp
        }
        self.duration = timeStamp + duration - self.timeStamp
    }
    
    func writeSamples(_ samples: UnsafePointer<Int16>, count: UInt, timeStamp: TimeInterval, duration: TimeInterval) {
        
        // Temporary hack to avoid a bounds busting bug.
        // TODO: this should be part of the writeSamples function's circular buffer.
        let lastSamplesOffset = (count > capacity) ? count - capacity : 0
        
        // Convert the raw sample data into a normalized float array, normedSamples.
        
        // Convert SInt16 into float
        vDSP_vflt16(samples + Int(lastSamplesOffset), 1, &normalizationBuffer, 1, min(capacity, count))
        
        // Normalise
        var scale: Float = 1.0/Float(Int16.max)
        vDSP_vsmul(&normalizationBuffer, 1, &scale, &normalizationBuffer, 1, min(capacity, count))
        writeSamples(&normalizationBuffer, count: min(capacity, count), timeStamp: timeStamp, duration: duration)
    }    
}
