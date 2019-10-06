//
//  DesktopOpenGLView.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 14/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Cocoa
import Foundation
import SpectroCoreOSX

class DesktopOpenGLView: NSOpenGLView {
    
    var namesForScrollingDirections: [String] {
        return renderer.namesForScrollingDirections
    }
    
    private var displayTimer: Timer?
    private var renderer: GLRenderer = GLRenderer(colorMapProvider: ColorMapStore()) // TODO:
        
    func use(_ settings: ApplicationSettings) {
        renderer.use(settings)
    }
    
    func addMeasurements(toDisplayQueue spectrums: [TimeSequence]) {
        
        execute(flushingBuffer: false) {
            renderer.addMeasurements(spectrums)
        }
    }

    func pauseRendering() {
        displayTimer?.invalidate()
        displayTimer = nil
    }
    
    func resumeRendering() {
        
        guard displayTimer == nil else {
            return
        }

        let timer = Timer(timeInterval: 0.001, repeats: true) { [weak self] _ in
            self?.render()
        }

        RunLoop.main.scheduleTimer(timer, forModes: [.default, .eventTracking, .modalPanel])
    }
    
    private func render() {

        execute(flushingBuffer: true) {
            renderer.render()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let attributes: [NSOpenGLPixelFormatAttribute] = [
            UInt32(NSOpenGLPFADoubleBuffer),
            UInt32(NSOpenGLPFAColorSize), 24,
            UInt32(NSOpenGLPFAAlphaSize), 8,
            UInt32(NSOpenGLPFAOpenGLProfile), UInt32(NSOpenGLProfileVersion3_2Core)
        ]
        
        guard let pformat = NSOpenGLPixelFormat(attributes: attributes) else {
            return
        }
        openGLContext = NSOpenGLContext(format: pformat, share: nil)
        pixelFormat = pformat
        wantsBestResolutionOpenGLSurface = true
    }

    override func prepareOpenGL() {
        super.prepareOpenGL()
        // Ensure we sync buffer swapping
        var swapInterval: GLint = 1
        openGLContext?.setValues(&swapInterval, for: .swapInterval)
    }
    
    override func update() {
        super.update()
        let renderSize = convertToBacking(bounds).size
        renderer.renderSize = RenderSize(width: GLint(renderSize.width), height: GLint(renderSize.height))
    }

    private func execute(flushingBuffer flush: Bool, _ glCommands: () -> Void) {

        guard let context = openGLContext else {
            return
        }
        context.makeCurrentContext()
        
        guard let cgl = context.cglContextObj else {
            return
        }
        
        CGLLockContext(cgl)
        glCommands()
        if flush {
            //    glSwapAPPLE(); // Consider swap instead.
            context.flushBuffer()
        }
        CGLUnlockContext(cgl)
    }
}

private extension RunLoop {
    
    func scheduleTimer(_ timer: Timer, forModes modes: [Mode]) {
        
        modes.forEach {
            add(timer, forMode: $0)
        }
    }
}
