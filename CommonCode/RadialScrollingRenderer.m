//
//  RadialScrollingRenderer.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 13/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "RadialScrollingRenderer.h"
#import <GLKit/GLKit.h>
#import "RendererUtils.h"
#import "RendererDefs.h"

static NSUInteger const NumberOfSpokes = 48;
static NSUInteger const NumberOfVerticesPerSpoke = 4;
static NSUInteger const NumberOfBufferVertices = (NumberOfSpokes + 1) * NumberOfVerticesPerSpoke;

@interface RadialScrollingRenderer ()
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint texOffsetUniform;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLuint vao;
@property (nonatomic) GLuint mesh;

@property (nonatomic) TexturedVertexAttribs* vertices;
@end

@implementation RadialScrollingRenderer

#pragma mark - ScrollingRenderer -

@synthesize scrollingPosition = _scrollingPosition;
@synthesize activeScrollingDirectionIndex = _activeScrollingDirectionIndex;

- (RenderSize)bestRenderSizeFromSize:(RenderSize)size
{
    return size;
}

- (NSArray*)namesForScrollingDirections
{
    return @[ NSLocalizedString(@"Outwards", @""), NSLocalizedString(@"Inwards", @"") ];
}

- (void)render
{
    if(!self.vertices)
    {
        [self initializeMeshForScrollingPosition];
    }
    
    if(!self.shader)
    {
        self.shader = [RendererUtils loadShaderProgramNamed:@"RadialScrollingShader"];
        self.textureUniform = glGetUniformLocation(self.shader, "uTextureSampler");
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.texCoordAttribute = glGetAttribLocation(self.shader, "aTexCoord");
        self.texOffsetUniform = glGetUniformLocation(self.shader, "uTexOffset");
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
    
    self.mesh = [self generateMeshUsingBufferName:self.mesh];
    if(!hasVAO)
    {
        glEnableVertexAttribArray(self.positionAttribute);
        glEnableVertexAttribArray(self.texCoordAttribute);
        glVertexAttribPointer(self.positionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, x));
        glVertexAttribPointer(self.texCoordAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, s));
    }

    [self updateMeshForScrollingPosition];

    glActiveTexture(GL_TEXTURE0);
    glUseProgram(self.shader);
    glUniform1i(self.textureUniform, 0);
    
//    const GLKVector2 offset = GLKVector2Make(self.scrollingPosition, 0.0f);
///    glUniform2fv(self.texOffsetUniform, 1, offset.v);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, NumberOfBufferVertices);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    [RendererUtils bindVAO:0];
}

#pragma mark - Lifecycle -

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

#pragma mark - Helpers -

- (GLuint)generateMeshUsingBufferName:(GLuint)bufferName
{
    if(!self.vertices)
    {
        return 0;
    }
    
    if(!bufferName)
    {
        glGenBuffers(1, &bufferName);
    }
    glBindBuffer(GL_ARRAY_BUFFER, bufferName);
    glBufferData(GL_ARRAY_BUFFER, sizeof(TexturedVertexAttribs)*NumberOfBufferVertices, self.vertices, GL_STREAM_DRAW);
    
    GL_DEBUG_GENERAL;
    
    return bufferName;
}

- (void)initializeMeshForScrollingPosition
{
    NSParameterAssert(!self.vertices);
    self.vertices = (TexturedVertexAttribs*)calloc(NumberOfBufferVertices, sizeof(TexturedVertexAttribs));
    const NSUInteger stripOffset = NumberOfBufferVertices/2;
    for(NSUInteger spokeIndex = 0; spokeIndex <= NumberOfSpokes; spokeIndex++)
    {
        const float fractionOfEdges = (float)spokeIndex/(float)NumberOfSpokes;
        const float angle = 2.0f*M_PI*fractionOfEdges;
        const float innerRadius = 0.0f;
        const float outerRadius = 1.0f;
        const GLKVector2 position = GLKVector2Make(sinf(angle), cosf(angle));
        
        const NSUInteger innerVertexIndex = spokeIndex * 2; // 2 points per strip
        const NSUInteger outerVertexIndex = innerVertexIndex + stripOffset + 1;
        self.vertices[innerVertexIndex] = (TexturedVertexAttribs) { position.x*innerRadius, position.y*innerRadius, 0.0f, fractionOfEdges };
        self.vertices[innerVertexIndex+1] = (TexturedVertexAttribs) { position.x*innerRadius, position.y*innerRadius, 1.0f, fractionOfEdges };
        self.vertices[outerVertexIndex-1] = (TexturedVertexAttribs) { position.x*innerRadius, position.y*innerRadius, 0.0f, fractionOfEdges };
        self.vertices[outerVertexIndex] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, 0.0f, fractionOfEdges };
    }
    
    GL_DEBUG_GENERAL;
}

- (void)updateMeshForScrollingPosition
{
    const float discontinuityRadius = self.scrollingPosition;
    const float edgeV = 1.0f - self.scrollingPosition;
    const NSUInteger stripOffset = NumberOfBufferVertices/2;
    for(NSUInteger spokeIndex = 0; spokeIndex <= NumberOfSpokes; spokeIndex++)
    {
        const NSUInteger innerVertexIndex = spokeIndex * 2; // 2 points per strip
        const NSUInteger outerVertexIndex = innerVertexIndex + stripOffset + 1;
/*        self.vertices[innerVertexIndex].s = edgeV;
        self.vertices[outerVertexIndex].s = edgeV;
        self.vertices[innerVertexIndex+1].x = self.vertices[outerVertexIndex-1].x = edgeV * self.vertices[innerVertexIndex].x + discontinuityRadius * self.vertices[outerVertexIndex].x;
        self.vertices[innerVertexIndex+1].y = self.vertices[outerVertexIndex-1].y = edgeV * self.vertices[innerVertexIndex].y + discontinuityRadius * self.vertices[outerVertexIndex].y;
 */
        self.vertices[innerVertexIndex].s = discontinuityRadius;
        self.vertices[outerVertexIndex].s = discontinuityRadius;
        self.vertices[innerVertexIndex+1].x = self.vertices[outerVertexIndex-1].x = discontinuityRadius * self.vertices[innerVertexIndex].x + edgeV * self.vertices[outerVertexIndex].x;
        self.vertices[innerVertexIndex+1].y = self.vertices[outerVertexIndex-1].y = discontinuityRadius * self.vertices[innerVertexIndex].y + edgeV * self.vertices[outerVertexIndex].y;

    }
    
    GL_DEBUG_GENERAL;
}

@end
