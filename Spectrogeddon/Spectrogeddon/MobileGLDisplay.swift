#if canImport(GLKit)

//
//  MobileGLDisplay.swift
//  Spectrogeddon
//
//  Created by Tom York on 13/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

// TODO: Use Metal
@MainActor
@available(iOS, deprecated: 12.0, message: "Uses the legacy OpenGL ES renderer.")
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
        guard let view = glView else {
            return
        }

        execute {
            renderer.renderSize = RenderSize(
                width: GLint(view.drawableWidth),
                height: GLint(view.drawableHeight)
            )
            view.display()
        }
    }
    
    func addMeasurement(toDisplayQueue timeSequence: TimeSequence) {
        execute {
            renderer.addMeasurements([timeSequence])
        }
    }

    private func execute(_ commands: () -> Void) {
        guard let context = context else {
            return
        }

        EAGLContext.setCurrent(context)
        commands()
    }
}

@available(iOS, deprecated: 12.0, message: "Uses the legacy OpenGL ES renderer.")
extension MobileGLDisplay: @preconcurrency GLKViewDelegate {
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        execute {
            renderer.render()
        }
    }
}

#endif
