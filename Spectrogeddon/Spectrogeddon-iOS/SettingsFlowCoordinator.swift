//
//  SettingsFlowCoordinator.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 01/11/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit
import SpectroCoreiOS

protocol SettingsFlowCoordinatorDelegate: class {
    func didChangeSettings()
    func didFinishSettingsFlow()
}

class SettingsFlowCoordinator {
    
    weak var delegate: SettingsFlowCoordinatorDelegate?
    
    private let store: SettingsStore
    private let parentViewController: UIViewController
    private var autoStopTimer: Timer?

    init(parentViewController: UIViewController, store: SettingsStore) {
        self.store = store
        self.parentViewController = parentViewController
    }
    
    deinit {
        autoStopTimer?.invalidate()
    }

    func start() {

        let settingsVC = SettingsViewController(store: store)
        settingsVC.delegate = self

        let navVC = UINavigationController(rootViewController: settingsVC)
        navVC.navigationBar.barStyle = .black
        navVC.modalTransitionStyle = .crossDissolve
        navVC.modalPresentationStyle = .overCurrentContext
        parentViewController.present(navVC, animated: true) { [weak self] in
            self?.scheduleAutomaticStop()
        }
    }
    
    private func stop() {
        parentViewController.dismiss(animated: true) { [weak self] in
            self?.delegate?.didFinishSettingsFlow()
        }
    }
    
    private func scheduleAutomaticStop() {

        autoStopTimer?.invalidate()
        autoStopTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { [weak self] _ in
            self?.stop()
        }
    }
}

extension SettingsFlowCoordinator: SettingsViewControllerDelegate {
    func didTapBackground() {
        stop()
    }
    
    func didChangeSetting() {
        scheduleAutomaticStop()
        delegate?.didChangeSettings()
    }
}
