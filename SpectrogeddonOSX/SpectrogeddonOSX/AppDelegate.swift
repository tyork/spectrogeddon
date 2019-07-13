//
//  AppDelegate.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 13/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet
    unowned var window: NSWindow!
    
    @IBOutlet
    var glView: DesktopOpenGLView!
    
    @IBOutlet
    var stretchFrequenciesMenuItem: NSMenuItem!
    
    @IBOutlet
    var sourceMenu: NSMenu!
    
    @IBOutlet
    var sharpnessMenu: NSMenu!

    @IBOutlet
    var scrollingDirectionsMenu: NSMenu!

    @IBOutlet
    var speedMenu: NSMenu!
    
    private var spectrumGenerator: SpectrumGenerator
    private var colorMapStore: ColorMapStore
    private var settingsStore: SettingsStore
    
    override init() {
        self.colorMapStore = ColorMapStore()
        self.settingsStore = SettingsStore()
        self.spectrumGenerator = try! SpectrumGenerator()// TODO:

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
     
        if settingsStore.displaySettings.colorMap == nil {
            settingsStore.displaySettings.colorMap = colorMapStore.currentMap
        }
        
        if settingsStore.displaySettings.preferredAudioSourceId == nil {
            settingsStore.displaySettings.preferredAudioSourceId = SpectrumGenerator.availableSources.values.first
        }
        
        glView.use(settingsStore.displaySettings)
        spectrumGenerator.useSettings(settingsStore.displaySettings)
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
        speedMenu.removeAllItems()
        
        let currentSpeed = settingsStore.displaySettings.scrollingSpeed
        
        let speeds = [ 1, 2, 4, 8 ]
        for speed in speeds {
            let title = "\(speed)"
            let charCode: String = title.count == 1 ? title.prefix(1).lowercased() : ""
            let item = NSMenuItem(title: title, action: #selector(didPickSpeed(_:)), keyEquivalent: charCode)
            item.state = (speed == currentSpeed) ? .on : .off
            item.representedObject = speed
            speedMenu.addItem(item)
        }
    }
    
    func updateSourceMenu() {
        sourceMenu.removeAllItems()
        
        let availableSources = SpectrumGenerator.availableSources
        
        let currentSourceId = settingsStore.displaySettings.preferredAudioSourceId
        
        for (name, id) in availableSources {
            let item = NSMenuItem(title: name, action: #selector(didPickSource(_:)), keyEquivalent: "")
            item.state = (currentSourceId == id) ? .on : .off
            item.representedObject = id
            sourceMenu.addItem(item)
        }
    }
    
    func updateScrollingDirectionsMenu() {
        scrollingDirectionsMenu.removeAllItems()
        
        let current = settingsStore.displaySettings.scrollingDirectionIndex
        
        for (index, name) in glView.namesForScrollingDirections.enumerated() {
            let charCode: String = name.prefix(1).lowercased()
            let item = NSMenuItem(title: name, action: #selector(didPickScrollDirection(_:)), keyEquivalent: charCode)
            item.state = (current == index) ? .on : .off
            item.representedObject = index
            scrollingDirectionsMenu.addItem(item)
        }
    }
    
    func updateDisplayMenu() {
        stretchFrequenciesMenuItem.state = settingsStore.displaySettings.useLogFrequencyScale ? .on : .off
    }
    
    func updateSharpnessMenu() {
        sharpnessMenu.removeAllItems()

        let currentSharpness = settingsStore.displaySettings.sharpness
        
        let sharpnessValues = [ 4, 2, 1]
        
        for value in sharpnessValues {
           let item = NSMenuItem(title: "\(value)@x", action: #selector(didPickSharpness(_:)), keyEquivalent: "")
            item.state = (value == currentSharpness) ? .on : .off
            item.representedObject = value
            sharpnessMenu.addItem(item)
        }
    }
    
    // Actions
    
    @IBAction
    func nextColorMap(_ sender: NSMenuItem) {
        settingsStore.displaySettings.colorMap = colorMapStore.nextMap()
        glView.use(settingsStore.displaySettings)
    }
    
    @IBAction
    func changeFrequencyScale(_ sender: NSMenuItem) {
        settingsStore.displaySettings.useLogFrequencyScale = !settingsStore.displaySettings.useLogFrequencyScale
        glView.use(settingsStore.displaySettings)
        updateDisplayMenu()
    }

    @objc
    func didPickScrollDirection(_ sender: NSMenuItem) {
        guard let scrollingDirection = sender.representedObject as? UInt else {
            return
        }
        settingsStore.displaySettings.scrollingDirectionIndex = scrollingDirection
        glView.use(settingsStore.displaySettings)
        updateScrollingDirectionsMenu()
    }
    
    @objc
    func didPickSpeed(_ sender: NSMenuItem) {
        guard let speed = sender.representedObject as? Int else {
            return
        }
        settingsStore.displaySettings.scrollingSpeed = speed
        glView.use(settingsStore.displaySettings)
        updateSpeedMenu()
    }
    
    @objc
    func didPickSharpness(_ sender: NSMenuItem) {
        guard let sharpness = sender.representedObject as? UInt else {
            return
        }
        settingsStore.displaySettings.sharpness = sharpness
        spectrumGenerator.useSettings(settingsStore.displaySettings)
        updateSharpnessMenu()
    }
    
    @objc
    func didPickSource(_ sender: NSMenuItem) {
        guard let sourceID = sender.representedObject as? String else {
            return
        }
        settingsStore.displaySettings.preferredAudioSourceId = sourceID
        spectrumGenerator.useSettings(settingsStore.displaySettings)
        updateSourceMenu()
    }
}

extension AppDelegate: SpectrumGeneratorDelegate {
    
    func spectrumGenerator(_ generator: SpectrumGenerator, didGenerate spectrumsPerChannel: [TimeSequence]) {
        glView.addMeasurements(toDisplayQueue: spectrumsPerChannel)
    }
}
