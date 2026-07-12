//
//  SpectrumGenerator.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 14/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//
import Foundation

public protocol SpectrumGeneratorDelegate: AnyObject {
    // Marking just this function as @MainActor ensures that whoever receives
    // the audio data (UI/Renderers) processes it safely on the main thread.
    @MainActor func spectrumGenerator(_ generator: SpectrumGenerator, didGenerate spectrums: [TimeSequence])
}

// Reverted @MainActor and added @unchecked Sendable
public class SpectrumGenerator: @unchecked Sendable {
    
    public typealias SourceName = String
    public typealias SourceID = String
    
    public static var availableSources: [SourceName: SourceID] {
        return AudioSource.availableAudioSources
    }

    public weak var delegate: SpectrumGeneratorDelegate?
    
    private let transformer: FastFourierTransform
    private let queue: DispatchQueue
    private var audioSource: AudioSource!

    public init() throws {
        transformer = FastFourierTransform()
        queue = DispatchQueue(label: "fft", qos: .default)
        
        audioSource = try AudioSource(notificationQueue: queue) { [weak self] channels in
            guard let strongSelf = self else { return }
            
            // 1. Heavy FFT math processing runs sequentially on your background queue
            let spectrums: [TimeSequence] = channels.compactMap {
                return strongSelf.transformer.transform($0)
            }
            
            // 2. Dispatch data back to the main thread cleanly, bypassing
            // the brittle runtime Actor thunks that caused the crash.
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
