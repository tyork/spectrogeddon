//
//  AppDelegate.swift
//  Spectrogeddon-OSX
//
//  Created by Tom York on 13/07/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import Cocoa
import SpectroCoreOSX

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet unowned var window: NSWindow!
    @IBOutlet var glView: DesktopOpenGLView!
    @IBOutlet var stretchFrequenciesMenuItem: NSMenuItem!
    @IBOutlet var sourceMenu: NSMenu!
    @IBOutlet var sharpnessMenu: NSMenu!
    @IBOutlet var scrollingDirectionsMenu: NSMenu!
    @IBOutlet var speedMenu: NSMenu!
    
    private var spectrumGenerator: SpectrumGenerator
    private var settingsStore: SettingsStore
    
    override init() {
        
        self.settingsStore = SettingsStore()
        self.spectrumGenerator = try! SpectrumGenerator(initialAudioSourceID: settingsStore.settings.preferredAudioSourceId.value)
        
        super.init()
        
        spectrumGenerator.delegate = self
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        applyStoredSettings()
        
        updateAllMenus()
        
        resume()
    }
    
    func applicationDidUnhide(_ notification: Notification) {
        resume()
    }
    
    func applicationDidHide(_ notification: Notification) {
        pause()
    }
    
    private func applyStoredSettings() {

        glView.use(settingsStore.settings)
        spectrumGenerator.useSettings(settingsStore.settings)
    }
    
    private func updateAllMenus() {
        
        updateSourceMenu()
        updateSpeedMenu()
        updateSharpnessMenu()
        updateDisplayMenu()
        updateScrollingDirectionsMenu()
    }
    
    private func pause() {
        glView.pauseRendering()
        spectrumGenerator.stop()
    }
    
    private func resume() {
        glView.resumeRendering()
        spectrumGenerator.start()
    }
    
    // Menu updates
    
    func updateSpeedMenu() {
        let setting = settingsStore.settings.scrollingSpeed
        speedMenu.replaceItems(fromSetting: setting, selector: #selector(didPickSpeed(_:)))
    }
    
    func updateSourceMenu() {
        // no shortcut
        let setting = settingsStore.settings.preferredAudioSourceId
        sourceMenu.replaceItems(fromSetting: setting, selector: #selector(didPickSource(_:)))
    }
    
    func updateScrollingDirectionsMenu() {
        //            let charCode: String = name.prefix(1).lowercased()
        let setting = settingsStore.settings.scrollingDirectionIndex
        scrollingDirectionsMenu.replaceItems(fromSetting: setting, selector: #selector(didPickScrollDirection(_:)))
    }
    
    func updateDisplayMenu() {
        stretchFrequenciesMenuItem.state = settingsStore.settings.useLogFrequencyScale.value ? .on : .off
    }
    
    func updateSharpnessMenu() {
        //\(value)@x
        let setting = settingsStore.settings.sharpness
        sharpnessMenu.replaceItems(fromSetting: setting, selector: #selector(didPickSharpness(_:)))
    }
    
    // Actions
    
    @IBAction
    func nextColorMap(_ sender: NSMenuItem) {
        
        settingsStore.update { oldSettings in
            var newSettings = oldSettings
            newSettings.colorMapName.nextValue()
            return newSettings
        }
        
        glView.use(settingsStore.settings)
    }
    
    @IBAction
    func changeFrequencyScale(_ sender: NSMenuItem) {
        
        settingsStore.update { oldSettings in
            var newSettings = oldSettings
            newSettings.useLogFrequencyScale.nextValue()
            return newSettings
        }

        glView.use(settingsStore.settings)
        updateDisplayMenu()
    }
    
    @objc
    func didPickScrollDirection(_ sender: NSMenuItem) {
        guard let scrollingDirection = sender.representedObject as? UInt else {
            return
        }
        settingsStore.settings.scrollingDirectionIndex.value = scrollingDirection
        glView.use(settingsStore.settings)
        updateScrollingDirectionsMenu()
    }
    
    @objc
    func didPickSpeed(_ sender: NSMenuItem) {
        guard let speed = sender.representedObject as? Int else {
            return
        }
        settingsStore.settings.scrollingSpeed.value = speed
        glView.use(settingsStore.settings)
        updateSpeedMenu()
    }
    
    @objc
    func didPickSharpness(_ sender: NSMenuItem) {
        guard let sharpness = sender.representedObject as? UInt else {
            return
        }
        settingsStore.settings.sharpness.value = sharpness
        spectrumGenerator.useSettings(settingsStore.settings)
        updateSharpnessMenu()
    }
    
    @objc
    func didPickSource(_ sender: NSMenuItem) {
        guard let sourceID = sender.representedObject as? String else {
            return
        }
        settingsStore.settings.preferredAudioSourceId.value = sourceID
        spectrumGenerator.useSettings(settingsStore.settings)
        updateSourceMenu()
    }
}

extension AppDelegate: SpectrumGeneratorDelegate {
    
    func spectrumGenerator(_ generator: SpectrumGenerator, didGenerate spectrumsPerChannel: [TimeSequence]) {
        glView.addMeasurements(toDisplayQueue: spectrumsPerChannel)
    }
}
