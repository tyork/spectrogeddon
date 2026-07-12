//
//  SettingsViewController.swift
//  Spectrogeddon
//
//  Created by Tom York on 12/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit

class SettingsViewController : UIViewController {
    
    private var dismissalTimer: Timer?
    
    private var model: SettingsWrapper = SettingsWrapper()
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissalTimer?.invalidate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scheduleAutomaticDismissal()
    }

    @IBAction
    func changeColors() {
        settingsModel.nextColorMap()
        scheduleAutomaticDismissal()
    }

    @IBAction
    func toggleFrequencyStretch() {
        settingsModel.toggleFrequencyStretch()
        scheduleAutomaticDismissal()
    }

    @IBAction
    func changeScrollingSpeed() {
        settingsModel.nextScrollingSpeed()
        scheduleAutomaticDismissal()
    }
    
    @IBAction
    func changeSharpness() {
        settingsModel.nextSharpness()
        scheduleAutomaticDismissal()
    }
    
    func scheduleAutomaticDismissal() {
        dismissalTimer?.invalidate()
        dismissalTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { [weak self] _ in
            

            Task { @MainActor in
                if let strongSelf = self {
                    strongSelf.performSegue(withIdentifier: "dismissSettings", sender: strongSelf)
                }
            }
        }
    }
}


extension SettingsViewController: SettingsModelClient {
    
    var settingsModel: SettingsWrapper {
        get {
            return model
        }
        set(settingsModel) {
            model = settingsModel
        }
    }
}
