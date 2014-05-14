//
//  SampleSetMesh.m
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import "ColumnRenderer.h"
#import "TimeSequence.h"
#import "RendererDefs.h"
#import "RendererUtils.h"
#import "RendererTypes.h"

@interface ColumnRenderer ()
@property (nonatomic,strong) GLKTextureInfo* texture;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLint texCoordAttribute;
@property (nonatomic) GLint textureUniform;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLuint mesh;
@property (nonatomic) GLuint vao;

@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) TexturedVertexAttribs* vertices;
@property (nonatomic) GLsizei vertexCount;
@property (nonatomic) BOOL invalidatedVertices;
@end


@implementation ColumnRenderer

- (instancetype)init
{
    if((self = [super init]))
    {
        _positioning = GLKMatrix4Identity;
    }
    return self;
}

- (void)dealloc
{
    [RendererUtils destroyVAO:_vao];
    glDeleteProgram(_shader);
    glDeleteBuffers(1, &_mesh);
    free(_vertices);
    CGImageRelease(_colorMapImage);
}

- (void)setColorMapImage:(CGImageRef)colorMapImage
{
    if(_colorMapImage != colorMapImage)
    {
        CGImageRelease(_colorMapImage);
        _colorMapImage = colorMapImage;
        CGImageRetain(colorMapImage);
        self.texture = nil;
    }
}

- (void)setUseLogFrequencyScale:(BOOL)useLogFrequencyScale
{
    if(_useLogFrequencyScale != useLogFrequencyScale)
    {
        _useLogFrequencyScale = useLogFrequencyScale;
        self.invalidatedVertices = YES;
    }
}

- (void)generateVertexPositions
{
    const float logOffset = 0.001f; // Safety margin to ensure we don't try taking log2(0)
    const float logNormalization = 1.0f/log2f(logOffset);
    const float yScale = 1.0f / (float)(self.vertexCount/2 - 1);
    for(NSUInteger valueIndex = 0; valueIndex < self.vertexCount/2; valueIndex++)
    {
        const NSUInteger vertexIndex = valueIndex << 1;
        float y = (float)valueIndex * yScale;
        if(self.useLogFrequencyScale)
        {
            y = (1.0f-logNormalization*log2f(y+logOffset));
        }
        self.vertices[vertexIndex] = (TexturedVertexAttribs){ 0.0f, y, 0.0f, 0.0f };
        self.vertices[vertexIndex+1] = (TexturedVertexAttribs){ 1.0f, y, 0.0f, 0.0f };
    }
}

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence offset:(float)offset width:(float)width
{
    if(!timeSequence.numberOfValues)
    {
        return;
    }
    
    const GLsizei vertexCountForSequence = (GLsizei)(timeSequence.numberOfValues * 2);
    const BOOL needsVertexes = (self.vertexCount != vertexCountForSequence) || self.invalidatedVertices;
    if(needsVertexes)
    {
        if(self.vertices != NULL)
        {
            free(self.vertices);
            self.vertices = NULL;
        }
        self.vertexCount = vertexCountForSequence;
        self.vertices = (TexturedVertexAttribs*)calloc(self.vertexCount, sizeof(TexturedVertexAttribs));
        [self generateVertexPositions];
        self.invalidatedVertices = NO;
    }

    const GLKMatrix4 translation = GLKMatrix4MakeTranslation(offset, 0.0f, 0.0f);
    self.transform = GLKMatrix4Multiply(GLKMatrix4Scale(translation, width, 1.0f, 1.0f), self.positioning);
    for(NSUInteger valueIndex = 0; valueIndex < timeSequence.numberOfValues; valueIndex++)
    {
        const NSUInteger vertexIndex = valueIndex << 1;
        const float value = [timeSequence valueAtIndex:valueIndex];
        self.vertices[vertexIndex].t = value;
        self.vertices[vertexIndex+1].t = value;
    }
}

- (void)render
{
    if(!self.vertices || !self.colorMapImage)
    {
        return;
    }
    
    if(!self.texture && self.colorMapImage)
    {
        self.texture = [GLKTextureLoader textureWithCGImage:self.colorMapImage options:nil error:nil];
    }
    if(!self.shader)
    {
        self.shader = [RendererUtils loadShaderProgramNamed:@"TexturedMeshShader"];
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.texCoordAttribute = glGetAttribLocation(self.shader, "aTexCoord");
        self.textureUniform = glGetUniformLocation(self.shader, "uTextureSampler");
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
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    glUseProgram(self.shader);
    glUniform1i(self.textureUniform, 0);
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, self.transform.m);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.mesh);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.vertexCount);

    [RendererUtils bindVAO:0];
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    GL_DEBUG_GENERAL;

}

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
    glBufferData(GL_ARRAY_BUFFER, sizeof(TexturedVertexAttribs)*self.vertexCount, self.vertices, GL_STREAM_DRAW);
    
    GL_DEBUG_GENERAL;
    
    return bufferName;
}

@end
