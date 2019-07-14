//
//  SpectrumGenerator.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 14/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

public protocol SpectrumGeneratorDelegate: class {
    func spectrumGenerator(_ generator: SpectrumGenerator, didGenerate spectrums: [TimeSequence])
}

public class SpectrumGenerator {
    
    public typealias SourceName = String
    public typealias SourceID = String
    
    public static var availableSources: [SourceName: SourceID] {
        return AudioSourceFinder.availableSources
    }

    public weak var delegate: SpectrumGeneratorDelegate?
    
    private let transformer: FastFourierTransform
    private let queue: DispatchQueue
    private var sampler: AudioSampler

    public init() throws {
        
        transformer = FastFourierTransform()
        queue = DispatchQueue(label: "fft", qos: .default)
        sampler = try AudioSampler(
            preferredSource: AudioSourceFinder.availableSources.values.first,
            notificationQueue: queue
        )
        
        sampler.sampleHandler = { [weak self] channels in
            
            guard let strongSelf = self else {
                return
            }
            
            let spectrums: [TimeSequence] = channels.compactMap {
                return strongSelf.transformer.transform($0)
            }
            
            DispatchQueue.main.async {
                strongSelf.delegate?.spectrumGenerator(strongSelf, didGenerate: spectrums)
            }
        }
    }
    
    public func start() {
        sampler.startCapturing()
    }
    
    public func stop() {
        sampler.stopCapturing()
    }
    
    public func useSettings(_ settings: DisplaySettings) {
        
        if let sourceId = settings.preferredAudioSourceId, SpectrumGenerator.availableSources.values.contains(sourceId) {
            sampler.preferredSource = sourceId
        }
        sampler.bufferSizeDivider = settings.sharpness
    }
}
