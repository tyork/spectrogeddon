//
//  MainFlowCoordinator.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 01/11/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit
import SpectroCoreiOS

class MainFlowCoordinator {
    
    var store: SettingsStore
    var window: UIWindow
    
    private var settingsCoordinator: SettingsFlowCoordinator?
    private var spectrumVC: SpectrumViewController?
    
    init(window: UIWindow, store: SettingsStore = SettingsStore()) {
        self.window = window
        self.store = store
    }
    
    func start() {
        let mainController = SpectrumViewController(store: store)
        spectrumVC = mainController
        mainController.delegate = self
        window.rootViewController = mainController
    }
    
    private func showSettingsFlow() {
        
        guard let parentVC = window.rootViewController else { return }
        
        let coordinator = SettingsFlowCoordinator(parentViewController: parentVC, store: store)
        coordinator.delegate = self
        settingsCoordinator = coordinator
        coordinator.start()
    }
}

extension MainFlowCoordinator: SpectrumViewControllerDelegate {
    
    func didTapBackground() {
        showSettingsFlow()
    }
}

extension MainFlowCoordinator: SettingsFlowCoordinatorDelegate {

    func didChangeSettings() {
        spectrumVC?.reloadSettings()
    }
    
    func didFinishSettingsFlow() {
        settingsCoordinator = nil
    }
}
