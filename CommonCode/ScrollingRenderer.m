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
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLuint vao;

@property (nonatomic) GLuint mesh;
@end

@implementation ScrollingRenderer

- (void)dealloc
{
    [self destroyMeshResources];
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

- (void)render
{
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

@end
