//
//  SpectrumViewController.swift
//  Spectrogeddon
//
//  Created by Tom York on 11/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit
import GLKit
import SpectroCoreiOS

class SpectrumViewController: UIViewController {
    
    @IBOutlet
    private var spectrumView: GLKView!
    private var displayLink: CADisplayLink!

    private var spectrumGenerator: SpectrumGenerator = try! SpectrumGenerator() // TODO:
    private var renderer: MobileGLDisplay = MobileGLDisplay()
    private let settingsModel: SettingsWrapper = SettingsWrapper()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {

        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink?.add(to: .main, forMode: .common)
        displayLink?.isPaused = true

        spectrumGenerator.delegate = self
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(pause), name: UIApplication.willResignActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(resume), name: UIApplication.didBecomeActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(didChangeSettings), name: .spectroSettingsDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func pause() {
        spectrumGenerator.stop()
        displayLink?.isPaused = true
    }
    
    @objc
    func resume() {
        spectrumGenerator.start()
        displayLink?.isPaused = false
    }
    
    @objc
    func didChangeSettings() {
        renderer.use(settingsModel.displaySettings)
        spectrumGenerator.useSettings(settingsModel.displaySettings)
    }

    @objc
    func updateDisplay() {
        renderer.redisplay()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderer.use(settingsModel.displaySettings)
        
        renderer.glView = spectrumView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spectrumView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction
    func unwindSegue(sender: UIStoryboardSegue) {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showControls" {

            let vc = segue.destination
            vc.modalPresentationCapturesStatusBarAppearance = true
            if var client = vc as? SettingsModelClient {
                client.settingsModel = settingsModel
            } else {
                for child in vc.children {
                    if var client = child as? SettingsModelClient {
                        client.settingsModel = settingsModel
                    }
                }
            }
        }
    }

}

extension SpectrumViewController: SpectrumGeneratorDelegate {
    
    func spectrumGenerator(_ generator: SpectrumGenerator, didGenerate spectrumsPerChannel: [TimeSequence]) {

        if let channel = spectrumsPerChannel.first {
            renderer.addMeasurement(toDisplayQueue: channel)
        }
    }
}
