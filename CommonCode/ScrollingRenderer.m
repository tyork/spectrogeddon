//
//  ScrollingRenderer.m
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import "ScrollingRenderer.h"
#import "RendererDefs.h"
#import "RendererUtils.h"

#define NumberOfBufferVertices 8

typedef struct
{
    GLfloat x,y;
    GLfloat s,t;
} TexturedVertexAttribs;

@interface ScrollingRenderer ()
@property (nonatomic) GLuint framebuffer;

@property (nonatomic) GLuint frameTexture;
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLuint vao;

@property (nonatomic) GLuint mesh;
@end

@implementation ScrollingRenderer

- (void)setRenderSize:(RenderSize)renderSize
{
    if(!RenderSizeEqualToSize(renderSize, _renderSize))
    {
        _renderSize = renderSize;
        [self destroyFrameResources];
    }
}

- (void)dealloc
{
    [self destroyMeshResources];
    [self destroyFrameResources];
}

- (void)destroyMeshResources
{
    if(self.mesh)
    {
        glDeleteBuffers(1, &_mesh);
        self.mesh = 0;
    }
    
    if(self.vao)
    {
#if TARGET_OS_IPHONE
        glDeleteVertexArraysOES(1, &_vao);
#else
        glDeleteVertexArrays(1, &_vao);
#endif
        self.vao = 0;
    }
    
    if(self.shader)
    {
        glDeleteProgram(self.shader);
        self.shader = 0;
        self.positionAttribute = 0;
        self.texCoordAttribute = 0;
        self.textureUniform = 0;
    }
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

- (void)render
{
    if(!self.frameTexture)
    {
       return;
    }
    
    if(!self.shader)
    {
        self.shader = [RendererUtils loadShaderProgramNamed:@"ScrollingShader"];
        self.textureUniform = glGetUniformLocation(self.shader, "uTextureSampler");
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.texCoordAttribute = glGetAttribLocation(self.shader, "aTexCoord");
        self.transformUniform = glGetUniformLocation(self.shader, "uTransform");
    }
    
    if(!self.vao)
    {
        self.vao = [self generateVAO];
    }
    else
    {
#if TARGET_OS_IPHONE
        glBindVertexArrayOES(self.vao);
#else
        glBindVertexArray(self.vao);
#endif
    }
    
    if(!self.mesh)
    {
        self.mesh = [self generateMesh];
        
        glEnableVertexAttribArray(self.positionAttribute);
        glEnableVertexAttribArray(self.texCoordAttribute);
        glVertexAttribPointer(self.positionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, x));
        glVertexAttribPointer(self.texCoordAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, s));
    }
    
    glBindTexture(GL_TEXTURE_2D, self.frameTexture);
    glActiveTexture(GL_TEXTURE0);
    glUseProgram(self.shader);
    glUniform1i(self.textureUniform, 0);
    
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, self.transform.m);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, NumberOfBufferVertices);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
#if TARGET_OS_IPHONE
    glBindVertexArrayOES(0);
#else
    glBindVertexArray(0);
#endif
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (GLuint)generateVAO
{
    GLuint vaoIndex = 0;
#if TARGET_OS_IPHONE
    glGenVertexArraysOES(1, &vaoIndex);
    glBindVertexArrayOES(vaoIndex);
#else
    glGenVertexArrays(1, &vaoIndex);
    glBindVertexArray(vaoIndex);
#endif
    
    GL_DEBUG_GENERAL;

    return vaoIndex;
}

- (GLuint)generateMesh
{
    GLuint meshName = 0;
    glGenBuffers(1, &meshName);
    glBindBuffer(GL_ARRAY_BUFFER, meshName);
    
    static const TexturedVertexAttribs bufferMesh[NumberOfBufferVertices] = {
        { -3.0f, +1.0f, 0.0f, 1.0f },
        { -3.0f, -1.0f, 0.0f, 0.0f },
        { -1.0f, +1.0f, 1.0f, 1.0f },
        { -1.0f, -1.0f, 1.0f, 0.0f },
        { -1.0f, +1.0f, 0.0f, 1.0f },
        { -1.0f, -1.0f, 0.0f, 0.0f },
        { +1.0f, +1.0f, 1.0f, 1.0f },
        { +1.0f, -1.0f, 1.0f, 0.0f }
    };
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(bufferMesh), bufferMesh, GL_STATIC_DRAW);
    
    GL_DEBUG_GENERAL;
    
    return meshName;
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
