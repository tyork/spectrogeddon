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

protocol SpectrumViewControllerDelegate: class {
    func didTapBackground()
}

class SpectrumViewController: UIViewController {
    
    weak var delegate: SpectrumViewControllerDelegate?
    
    private var glView: GLKView! = {
        
        let view = GLKView().usingAutolayout()
        if let context = EAGLContext(api: .openGLES2) {
            view.context = context
        }
        view.drawableColorFormat = .RGBA8888
        return view
    }()
    
    private var displayLink: CADisplayLink!
    private let presenter: SpectrumPresenter

    init(store: SettingsStore) {
        
        presenter = SpectrumPresenter(store: store)

        super.init(nibName: nil, bundle: nil)
        
        presenter.client = self

        displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
        displayLink.add(to: .main, forMode: .common)
        displayLink.isPaused = true

        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        nc.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not supported for use with Storyboards")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadSettings() {
        presenter.accept(.load)
    }
    
    @objc private func willResignActive() {
        presenter.accept(.willResignActive)
    }
    
    @objc private func didBecomeActive() {
        presenter.accept(.didBecomeActive)
    }
    
    @objc private func updateDisplay() {
        
        guard isViewLoaded else { return }
        
        let renderSize = RenderSize(
            width: GLint(glView.bounds.width * glView.contentScaleFactor),
            height: GLint(glView.bounds.height * glView.contentScaleFactor)
        )
        
        presenter.accept(.newFrameNeeded(renderSize))
    }
    
    @objc private func didTapBackground() {
        delegate?.didTapBackground()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(glView)
        glView.pinToSuperviewEdges()
        glView.delegate = self
        
        let tapper = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
        view.addGestureRecognizer(tapper)
        
        presenter.accept(.load)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.accept(.didAppear)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.accept(.willDisappear)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Why did we need this ??
        glView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension SpectrumViewController: SpectrumPresenterClient {
    
    func presenterDidUpdate(_ update: SpectrumPresenter.Update) {
        
        switch update {
        case .pausedStateChange(let isPaused):
            displayLink.isPaused = isPaused
            
        case .redisplay:
            glView.display()
        }
    }
}

extension SpectrumViewController: GLKViewDelegate {
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        presenter.accept(.drawNow)
    }
}
