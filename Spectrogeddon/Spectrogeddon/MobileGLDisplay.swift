//
//  MobileGLDisplay.swift
//  Spectrogeddon
//
//  Created by Tom York on 13/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import GLKit

// TODO: Use Metal
class MobileGLDisplay: NSObject {

    weak var glView: GLKView? {
        didSet {
            glView?.delegate = self
            if let context = context {
                glView?.context = context
            }
        }
    }
    
    private var context: EAGLContext?
    private var renderer: GLRenderer
    
    // TODO: Init needs to be failable
    override init() {
        self.context = EAGLContext(api: .openGLES2)
        self.renderer = GLRenderer()
        super.init()
    }
    
    func use(_ displaySettings: DisplaySettings) {
        renderer.use(displaySettings)
    }
    
    func redisplay() {
        if let view = glView {
            renderer.renderSize = RenderSize(
                width: GLint(view.bounds.width * view.contentScaleFactor),
                height: GLint(view.bounds.height * view.contentScaleFactor)
            )
            view.display()
        }
    }
    
    func addMeasurement(toDisplayQueue timeSequence: TimeSequence) {
        renderer.addMeasurements(forDisplay: [timeSequence])
    }
}

extension MobileGLDisplay: GLKViewDelegate {
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        renderer.render()
    }
}
