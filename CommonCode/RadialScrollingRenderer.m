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
@property (nonatomic) GLint transformUniform;
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
    return @[ NSLocalizedString(@"Inwards", @""), NSLocalizedString(@"Outwards", @"") ];
}

- (void)setActiveScrollingDirectionIndex:(NSUInteger)activeScrollingDirectionIndex
{
    if(_activeScrollingDirectionIndex != activeScrollingDirectionIndex)
    {
        _activeScrollingDirectionIndex = activeScrollingDirectionIndex;
        [self initializeVertices];
    }
}

- (void)render
{
    if(!self.vertices)
    {
        [self initializeVertices];
    }
    
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
    
    self.mesh = [self generateMeshUsingBufferName:self.mesh];
    if(!hasVAO)
    {
        glEnableVertexAttribArray(self.positionAttribute);
        glEnableVertexAttribArray(self.texCoordAttribute);
        glVertexAttribPointer(self.positionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, x));
        glVertexAttribPointer(self.texCoordAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertexAttribs), (void *)offsetof(TexturedVertexAttribs, s));
    }

    [self updateVerticesForScrollingPosition];

    glActiveTexture(GL_TEXTURE0);
    glUseProgram(self.shader);
    const GLKMatrix4 transform = GLKMatrix4Identity;
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, transform.m);
    glUniform1i(self.textureUniform, 0);
    
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

- (void)initializeVertices
{
    if(!self.vertices)
    {
        self.vertices = (TexturedVertexAttribs*)calloc(NumberOfBufferVertices, sizeof(TexturedVertexAttribs));
    }
    const NSUInteger stripOffset = NumberOfBufferVertices/2;
    const float innerRadius = 0.0f;
    const float outerRadius = sqrtf(2.0f);
    const float edgeV = (self.activeScrollingDirectionIndex == 0) ? 0.0f : 1.0f;
    for(NSUInteger spokeIndex = 0; spokeIndex <= NumberOfSpokes; spokeIndex++)
    {
        const float fractionOfEdges = (float)spokeIndex/(float)NumberOfSpokes;
        const float angle = 2.0f*M_PI*fractionOfEdges;
        const GLKVector2 position = GLKVector2Make(sinf(angle), cosf(angle));
        
        const NSUInteger innerVertexIndex = spokeIndex * 2; // 2 points per strip
        const NSUInteger outerVertexIndex = innerVertexIndex + stripOffset + 1;
        self.vertices[innerVertexIndex] = (TexturedVertexAttribs) { position.x*innerRadius, position.y*innerRadius, edgeV, fractionOfEdges };
        self.vertices[innerVertexIndex+1] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, 1.0f - edgeV, fractionOfEdges };
        self.vertices[outerVertexIndex-1] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, edgeV, fractionOfEdges };
        self.vertices[outerVertexIndex] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, edgeV, fractionOfEdges };
    }
}

- (void)updateVerticesForScrollingPosition
{
    const float offset = (self.activeScrollingDirectionIndex == 0) ? self.scrollingPosition : (1.0f - self.scrollingPosition);
    const float contraOffset = 1.0f - offset;
    const float edgeV = self.scrollingPosition;
    const NSUInteger stripOffset = NumberOfBufferVertices/2;
    for(NSUInteger spokeIndex = 0; spokeIndex <= NumberOfSpokes; spokeIndex++)
    {
        const NSUInteger innerVertexIndex = spokeIndex * 2; // 2 points per strip
        const NSUInteger outerVertexIndex = innerVertexIndex + stripOffset + 1;
        self.vertices[innerVertexIndex].s = self.vertices[outerVertexIndex].s = edgeV;
        self.vertices[innerVertexIndex+1].x = self.vertices[outerVertexIndex-1].x = offset * self.vertices[innerVertexIndex].x + contraOffset * self.vertices[outerVertexIndex].x;
        self.vertices[innerVertexIndex+1].y = self.vertices[outerVertexIndex-1].y = offset * self.vertices[innerVertexIndex].y + contraOffset * self.vertices[outerVertexIndex].y;
    }
}

@end
