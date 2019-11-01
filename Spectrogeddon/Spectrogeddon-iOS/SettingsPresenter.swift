//
//  SettingsPresenter.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 30/10/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Foundation
import SpectroCoreiOS

protocol SettingsPresenterClient: class {
    func settingsPresenterDidUpdate(_ update: SettingsPresenter.Update)
}

class SettingsPresenter {
    
    enum Action {
        case didAppear
        case nextColorMap
        case toggleLogFrequencyScale
        case nextScrollingSpeed
        case nextSharpness
    }

    enum Update {
        case settingsUpdate(ApplicationSettings)
    }
    
    weak var client: SettingsPresenterClient?
    private var store: SettingsStore

    private(set) var settings: ApplicationSettings {
        set {
            store.settings = newValue
        }
        get {
            return store.settings
        }
    }
    
    init(store: SettingsStore) {
        self.store = store
    }
    
    func accept(action: Action) {
        
        switch action {
        case .didAppear:
            break
            
        case .nextColorMap:
            settings.colorMapName.nextValue()
            reportSettingsChange()
            
        case .nextScrollingSpeed:
            settings.scrollingSpeed.nextValue()
            reportSettingsChange()

        case .nextSharpness:
            settings.sharpness.nextValue()
            reportSettingsChange()

        case .toggleLogFrequencyScale:
            settings.useLogFrequencyScale.nextValue()
            reportSettingsChange()
        }
    }

    private func reportSettingsChange() {
        client?.settingsPresenterDidUpdate(.settingsUpdate(settings))
    }
}

