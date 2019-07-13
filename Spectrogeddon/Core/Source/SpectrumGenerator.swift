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
        return AudioSource.availableAudioSources
    }

    public weak var delegate: SpectrumGeneratorDelegate?
    
    private let transformer: FastFourierTransform
    private let queue: DispatchQueue
    private var audioSource: AudioSource! // TODO: change API of AudioSource so we don't need force unwrapped

    public init() throws {
        transformer = FastFourierTransform()
        queue = DispatchQueue(label: "fft", qos: .default)
        audioSource = try AudioSource(notificationQueue: queue) { [weak self] channels in
            
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
        audioSource.startCapturing()
    }
    
    public func stop() {
        audioSource.stopCapturing()
    }
    
    public func useSettings(_ settings: DisplaySettings) {
        
        if let sourceId = settings.preferredAudioSourceId, SpectrumGenerator.availableSources.values.contains(sourceId) {
            audioSource.preferredAudioSourceId = sourceId
        }
        audioSource.bufferSizeDivider = settings.sharpness
    }
}
