//
//  ShadedMesh.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 15/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "ShadedMesh.h"
#import <GLKit/GLKit.h>
#import "RendererUtils.h"
#import "RendererDefs.h"

@interface ShadedMesh ()
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLuint vao;
@property (nonatomic) GLuint mesh;

@property (nonatomic) NSUInteger numberOfVertices;
@property (nonatomic) TexturedVertexAttribs* vertices;
@end

@implementation ShadedMesh

#pragma mark - Lifecycle -

- (instancetype)initWithNumberOfVertices:(NSUInteger)vertexCount vertexGenerator:(VertexGenerator)generator
{
    if((self = [super init]))
    {
        _numberOfVertices = vertexCount;
        _vertices = (TexturedVertexAttribs*)calloc(vertexCount, sizeof(TexturedVertexAttribs));
        [self updateVertices:generator];
    }
    return self;
}

- (void)resizeMesh:(NSUInteger)changedVertexCount
{
    if(changedVertexCount != self.numberOfVertices)
    {
        TexturedVertexAttribs* attribs = (TexturedVertexAttribs*)realloc(self.vertices, sizeof(TexturedVertexAttribs)*changedVertexCount);
        if(attribs)
        {
            self.vertices = attribs;
            self.numberOfVertices = changedVertexCount;
        }
    }
}

- (void)dealloc
{
    [RendererUtils destroyVAO:_vao];
    if(_mesh)
    {
        glDeleteBuffers(1, &_mesh);
    }
    
    if(_shader)
    {
        glDeleteProgram(_shader);
    }
    
    free(_vertices);
}

#pragma mark - Modify vertices

- (void)updateVertices:(VertexGenerator)generator
{
    NSParameterAssert(generator);
    generator(self.vertices);
}

#pragma mark - Rendering

- (void)render
{
    if(!self.shader)
    {
        self.shader = [RendererUtils loadShaderProgramNamed:@"TexturedMeshShader"];
        self.textureUniform = glGetUniformLocation(self.shader, "uTextureSampler");
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.texCoordAttribute = glGetAttribLocation(self.shader, "aTexCoord");
        self.transformUniform = glGetUniformLocation(self.shader, "uTransform");
    }
    
    const BOOL hasVAO = (self.vao != 0);
    if(!hasVAO)
    {
        self.vao = [RendererUtils generateVAO];
    }
    else
    {
        [RendererUtils bindVAO:self.vao];
    }
    
    self.mesh = [self generateArrayBufferForName:self.mesh];
    if(!hasVAO)
    {
        glEnableVertexAttribArray(self.positionAttribute);
        glEnableVertexAttribArray(self.texCoordAttribute);
        glVertexAttribPointer(self.positionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, x));
        glVertexAttribPointer(self.texCoordAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, s));
    }
    
    glActiveTexture(GL_TEXTURE0);
    glUseProgram(self.shader);
    const GLKMatrix4 transform = GLKMatrix4Identity;
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, transform.m);
    glUniform1i(self.textureUniform, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)self.numberOfVertices);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    [RendererUtils bindVAO:0];
}

#pragma mark - Helpers -

- (GLuint)generateArrayBufferForName:(GLuint)arrayBufferName
{
    if(!self.vertices)
    {
        return 0;
    }
    
    if(!arrayBufferName)
    {
        glGenBuffers(1, &arrayBufferName);
    }
    glBindBuffer(GL_ARRAY_BUFFER, arrayBufferName);
    glBufferData(GL_ARRAY_BUFFER, sizeof(TexturedVertexAttribs)*self.numberOfVertices, self.vertices, GL_STREAM_DRAW);
    
    GL_DEBUG_GENERAL;
    
    return arrayBufferName;
}


@end
