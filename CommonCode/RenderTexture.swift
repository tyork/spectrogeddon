//
//  RenderTexture.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 24/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import GLKit

/// Allows you to draw into a texture that can then be rendered to a framebuffer elsewhere.
class RenderTexture {

    var renderSize: RenderSize {
        didSet {
            if renderSize != oldValue {
                destroyFrameResources()
            }
        }
    }
    
    private var framebuffer: GLuint
    private var frameTexture: GLuint
    
    init() {
        self.framebuffer = 0
        self.frameTexture = 0
        self.renderSize = RenderSize(width: 0, height: 0)
    }
    
    deinit {
        destroyFrameResources()
    }
 
    /// Draw into the texture.
    func draw(commands: () -> Void) {
        
        guard renderSize != .empty else {
            return
        }
        
        if frameTexture <= 0 {
            frameTexture = generateTexture()
        }
        
        if framebuffer <= 0 {
            framebuffer = generateFrameBuffer(forTexture: frameTexture)
            glClearColor(0, 0, 0, 1)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        } else {
            glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        }
        
        glViewport(0, 0, renderSize.width, renderSize.height);
        commands()
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)

    }
    
    /// Binds the texture to TEXTURE2D before executing glCommands.
    func renderTexture(commands: () -> Void) {
        guard frameTexture > 0 else {
            return
        }
        glBindTexture(GLenum(GL_TEXTURE_2D), frameTexture)
        commands()
        glBindTexture(GLenum(GL_TEXTURE_2D), 0);
    }
    
    private func destroyFrameResources() {
        
        if framebuffer > 0 {
            glDeleteFramebuffers(1, &framebuffer)
            framebuffer = 0
        }
        
        if frameTexture > 0 {
            glDeleteTextures(1, &frameTexture)
            frameTexture = 0
        }
    }

    private func generateFrameBuffer(forTexture textureName: GLuint) -> GLuint {
        
        precondition(textureName > 0)
        var framebufferName: GLuint = 0
        glGenFramebuffers(1, &framebufferName)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebufferName)
        glFramebufferTexture2D(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_TEXTURE_2D), textureName, 0)
    
        let status = glCheckFramebufferStatus(GLenum(GL_FRAMEBUFFER))
        assert(status == GL_FRAMEBUFFER_COMPLETE, "Failed to make framebuffer: \(status)")
        return framebufferName
    }
    
    private func generateTexture() -> GLuint {
        
        let mode = GLenum(GL_TEXTURE_2D)
        
        var textureName: GLuint = 0
        glGenTextures(1, &textureName)
        glBindTexture(mode, textureName)
        glTexImage2D(mode, 0, GL_RGB, renderSize.width, renderSize.height, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)
        glTexParameteri(mode, GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(mode, GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        glTexParameterf(mode, GLenum(GL_TEXTURE_MIN_FILTER), GLfloat(GL_LINEAR))
        glTexParameterf(mode, GLenum(GL_TEXTURE_MAG_FILTER), GLfloat(GL_LINEAR))
        glBindTexture(mode, 0)
    
        //GL_DEBUG_GENERAL;
    
        return textureName
    }

}
