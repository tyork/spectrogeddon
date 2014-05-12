//
//  RenderTexture.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 12/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "RenderTexture.h"
#import "RendererDefs.h"
#import <GLKit/GLKit.h>

@interface RenderTexture ()
@property (nonatomic) GLuint framebuffer;
@property (nonatomic) GLuint frameTexture;
@end

@implementation RenderTexture

- (void)dealloc
{
    [self destroyFrameResources];
}

- (void)destroyFrameResources
{
    if(self.framebuffer)
    {
        glDeleteFramebuffers(1, &_framebuffer);
        self.framebuffer = 0;
    }
    
    if(self.frameTexture)
    {
        glDeleteTextures(1, &_frameTexture);
        self.frameTexture = 0;
    }
}

- (void)setRenderSize:(RenderSize)renderSize
{
    if(!RenderSizeEqualToSize(renderSize, _renderSize))
    {
        _renderSize = renderSize;
        [self destroyFrameResources];
    }
}

- (void)drawWithCommands:(void (^)(void))glCommands
{
    NSParameterAssert(glCommands);
    if(RenderSizeIsEmpty(self.renderSize))
    {
        return;
    }
    
    if(!self.frameTexture)
    {
        self.frameTexture = [self generateTexture];
    }
    
    if(!self.framebuffer)
    {
        self.framebuffer = [self generateFrameBufferForTexture:self.frameTexture];
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
    }
    else
    {
        glBindFramebuffer(GL_FRAMEBUFFER, self.framebuffer);
    }
    
    glViewport(0, 0, self.renderSize.width, self.renderSize.height);
    glCommands();
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)renderTextureWithCommands:(void(^)(void))glCommands
{
    NSParameterAssert(glCommands);
    glBindTexture(GL_TEXTURE_2D, self.frameTexture);
    glCommands();
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (GLuint)generateFrameBufferForTexture:(GLuint)textureName
{
    NSParameterAssert(textureName);
    GLuint framebufferName = 0;
    glGenFramebuffers(1, &framebufferName);
    glBindFramebuffer(GL_FRAMEBUFFER, framebufferName);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureName, 0);
    
    const GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert1(status == GL_FRAMEBUFFER_COMPLETE, @"Failed to make framebuffer: %d", status);
    return framebufferName;
}

- (GLuint)generateTexture
{
    GLuint textureName = 0;
    glGenTextures(1, &textureName);
    glBindTexture(GL_TEXTURE_2D, textureName);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, self.renderSize.width, self.renderSize.height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glBindTexture(GL_TEXTURE_2D, 0);
    
    GL_DEBUG_GENERAL;
    
    return textureName;
}

@end
