//
//  ScrollingRenderer.m
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import "LinearScrollingRenderer.h"
#import "RendererDefs.h"
#import "RendererUtils.h"

#define NumberOfBufferVertices 8

@interface LinearScrollingRenderer ()
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLuint vao;

@property (nonatomic) GLuint mesh;
@end

@implementation LinearScrollingRenderer

#pragma mark - ScrollingRenderer -

@synthesize scrollingPosition = _scrollingPosition;
@synthesize activeScrollingDirectionIndex = _activeScrollingDirectionIndex;

- (NSArray*)namesForScrollingDirections;
{
    return @[ NSLocalizedString(@"Horizontal", @""), NSLocalizedString(@"Vertical", @"") ];
}

- (RenderSize)bestRenderSizeFromSize:(RenderSize)size
{
    return (self.activeScrollingDirectionIndex == 0) ? size : (RenderSize) { size.height, size.width } ;
}

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
    
    const GLKMatrix4 transform = [self transform];
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, transform.m);
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

- (GLKMatrix4)transform
{
    const float translation = 2.0f * (1.0f - self.scrollingPosition);
    const GLKMatrix4 rotation = (self.activeScrollingDirectionIndex == 0) ? GLKMatrix4Identity : GLKMatrix4MakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    return GLKMatrix4Multiply(rotation, GLKMatrix4MakeTranslation(translation, 0.0f, 0.0f));
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
