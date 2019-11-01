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
    private var renderer: GLRenderer = GLRenderer(colorMapProvider: ColorMapStore())
        
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

        let timer = Timer(timeInterval: 0.01, repeats: true) { [weak self] _ in
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
        renderer.renderSize = RenderSize(convertToBacking(bounds).size)
    }

    private func execute(flushingBuffer flush: Bool, _ glCommands: () -> Void) {

        openGLContext?.performCommands(flushingBuffer: flush, glCommands)
    }
}

private extension NSOpenGLContext {
    
    func performCommands(flushingBuffer flush: Bool, _ glCommands: () -> Void) {
        
        makeCurrentContext()
        
        guard let cgl = cglContextObj else {
            return
        }
        
        CGLLockContext(cgl)
        glCommands()
        if flush {
            flushBuffer()
        }
        CGLUnlockContext(cgl)
    }
}

private extension RenderSize {
    
    init(_ size: CGSize) {
        self.init(width: GLint(size.width), height: GLint(size.height))
    }
}
