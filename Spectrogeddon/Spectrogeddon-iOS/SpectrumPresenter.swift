//
//  SpectrumPresenter.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 31/10/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import SpectroCoreiOS

protocol SpectrumPresenterClient: class {
    func presenterDidUpdate(_ update: SpectrumPresenter.Update)
}

class SpectrumPresenter {
    
    enum Action {
        case load
        case willResignActive
        case willDisappear
        case didBecomeActive
        case didAppear
        case newFrameNeeded(RenderSize)
        case drawNow
    }
    
    enum Update {
        case redisplay
        case pausedStateChange(Bool)
    }
    
    weak var client: SpectrumPresenterClient?
    private(set) var store: SettingsStore
    private var spectrumGenerator: SpectrumGenerator
    private var renderer: GLRenderer
    
    init(store: SettingsStore) {
        self.store = store
        renderer = GLRenderer(colorMapProvider: ColorMapStore())
        spectrumGenerator = try! SpectrumGenerator(initialAudioSourceID: store.settings.preferredAudioSourceId.value)
        spectrumGenerator.delegate = self
    }
    
    func accept(_ action: Action) {
        
        switch action {
        case .load:
            spectrumGenerator.useSettings(store.settings)
            renderer.use(store.settings)
            
        case .didBecomeActive, .didAppear:
            resume()
            
        case .willResignActive, .willDisappear:
            pause()
            
        case .newFrameNeeded(let renderSize):
            renderer.renderSize = renderSize
            client?.presenterDidUpdate(.redisplay)
        
        case .drawNow:
            renderer.render()
        }

    }

    private func pause() {
        spectrumGenerator.stop()
        client?.presenterDidUpdate(.pausedStateChange(true))
    }
    
    private func resume() {
        spectrumGenerator.start()
        client?.presenterDidUpdate(.pausedStateChange(false))
    }
}

extension SpectrumPresenter: SpectrumGeneratorDelegate {
    
    func spectrumGenerator(_ generator: SpectrumGenerator, didGenerate spectrumsPerChannel: [TimeSequence]) {

        if let channel = spectrumsPerChannel.first {
            renderer.addMeasurements([channel])
        }
    }
}
