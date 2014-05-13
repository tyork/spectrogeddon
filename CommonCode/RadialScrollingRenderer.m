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

static NSUInteger const NumberOfStrips = NumberOfVerticesPerSpoke/2;

static NSUInteger const NumberOfBufferVertices = (NumberOfSpokes + 1) * NumberOfStrips * 2;

@interface RadialScrollingRenderer ()
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint texOffsetUniform;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLuint vao;
@property (nonatomic) GLuint mesh;

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
    if(!self.shader)
    {
        self.shader = [RendererUtils loadShaderProgramNamed:@"RadialScrollingShader"];
        self.textureUniform = glGetUniformLocation(self.shader, "uTextureSampler");
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.texCoordAttribute = glGetAttribLocation(self.shader, "aTexCoord");
        self.texOffsetUniform = glGetUniformLocation(self.shader, "uTexOffset");
    }
    
    if(!self.vao)
    {
        self.vao = [RendererUtils generateVAO];
    }
    else
    {
        [RendererUtils bindVAO:self.vao];
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
    
    const GLKVector2 offset = GLKVector2Make(self.scrollingPosition, 0.0f);
    glUniform2fv(self.texOffsetUniform, 1, offset.v);
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
}

#pragma mark - Helpers -

- (GLuint)generateMesh
{
    GLuint meshName = 0;
    glGenBuffers(1, &meshName);
    glBindBuffer(GL_ARRAY_BUFFER, meshName);

    TexturedVertexAttribs* vertices = (TexturedVertexAttribs*)calloc(NumberOfBufferVertices, sizeof(TexturedVertexAttribs));
    for(NSUInteger stripIndex = 0, vertexIndex = 0; stripIndex < NumberOfStrips; stripIndex++)
    {
        const NSUInteger innerEdgeIndex = stripIndex;
        const NSUInteger outerEdgeIndex = stripIndex+1;
        const float innerRadius = 0.5f*(1.0f + innerEdgeIndex/(float)NumberOfStrips);
        const float outerRadius = 0.5f*(1.0f + outerEdgeIndex/(float)NumberOfStrips);
        const float innerV = innerEdgeIndex/(float)NumberOfStrips;
        const float outerV = outerEdgeIndex/(float)NumberOfStrips;
        
        for(NSUInteger spokeIndex = 0; spokeIndex <= NumberOfSpokes; spokeIndex++)
        {
            const float fractionOfEdges = (float)spokeIndex/(float)NumberOfSpokes;
            const float angle = 2.0f*M_PI*fractionOfEdges;
            const GLKVector2 position = GLKVector2Make(sinf(angle), cosf(angle));
            
            vertices[vertexIndex++] = (TexturedVertexAttribs) { position.x*innerRadius, position.y*innerRadius, innerV, fractionOfEdges };
            vertices[vertexIndex++] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, outerV, fractionOfEdges };
        }
    }
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(TexturedVertexAttribs)*NumberOfBufferVertices, vertices, GL_STATIC_DRAW);
    
    GL_DEBUG_GENERAL;
    
    return meshName;
}

@end
