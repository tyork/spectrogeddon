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

typedef struct
{
    GLfloat x,y;
    GLfloat level;
} LevelVertexAttribs;



@interface ColumnRenderer ()
@property (nonatomic,strong) GLKTextureInfo* texture;
@property (nonatomic) GLuint shader;
@property (nonatomic) GLint levelTextureSampler;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLint levelAttribute;
@property (nonatomic) GLint positionAttribute;
@property (nonatomic) GLuint mesh;
@property (nonatomic) GLuint vao;

@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) LevelVertexAttribs* vertices;
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
#if TARGET_OS_IPHONE
    glDeleteVertexArraysOES(1, &_vao);
#else
    glDeleteVertexArrays(1, &_vao);
#endif
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
    const float yScale = 2.0f / (float)(self.vertexCount/2 - 1);
    for(NSUInteger valueIndex = 0; valueIndex < self.vertexCount/2; valueIndex++)
    {
        const NSUInteger vertexIndex = valueIndex << 1;
        float y = (float)valueIndex * yScale;
        if(self.useLogFrequencyScale)
        {
            y = 2.0f*(1.0f-logNormalization*log2f(y*0.5f+logOffset));
        }
        self.vertices[vertexIndex] = (LevelVertexAttribs){ 0.0f, y, 0.0f };
        self.vertices[vertexIndex+1] = (LevelVertexAttribs){ 1.0f, y, 0.0f };
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
        self.vertices = (LevelVertexAttribs*)calloc(self.vertexCount, sizeof(LevelVertexAttribs));
        [self generateVertexPositions];
        self.invalidatedVertices = NO;
    }

    const GLKMatrix4 translation = GLKMatrix4MakeTranslation(offset, -1.0f, 0.0f);
    self.transform = GLKMatrix4Multiply(GLKMatrix4Scale(translation, width, 1.0f, 1.0f),self.positioning);
    
    for(NSUInteger valueIndex = 0; valueIndex < timeSequence.numberOfValues; valueIndex++)
    {
        const NSUInteger vertexIndex = valueIndex << 1;
        const float value = [timeSequence valueAtIndex:valueIndex];
        self.vertices[vertexIndex].level = value;
        self.vertices[vertexIndex+1].level = value;
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
        self.shader = [RendererUtils loadShaderProgramNamed:@"ColumnShader"];
        self.levelTextureSampler = glGetUniformLocation(self.shader, "uLevelSampler");
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.levelAttribute = glGetAttribLocation(self.shader, "aLevel");
        self.transformUniform = glGetUniformLocation(self.shader, "uTransform");
    }
    
    const BOOL hasVAO = (self.vao != 0);
    if(!hasVAO)
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

    self.mesh = [self generateMeshUsingBufferName:self.mesh];

    if(!hasVAO)
    {
        glEnableVertexAttribArray(self.positionAttribute);
        glEnableVertexAttribArray(self.levelAttribute);
        glVertexAttribPointer(self.positionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(LevelVertexAttribs), (void *)offsetof(LevelVertexAttribs, x));
        glVertexAttribPointer(self.levelAttribute, 1, GL_FLOAT, GL_FALSE, sizeof(LevelVertexAttribs), (void *)offsetof(LevelVertexAttribs, level));
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    glUseProgram(self.shader);
    glUniform1i(self.levelTextureSampler, 0);
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, self.transform.m);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.mesh);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.vertexCount);

#if TARGET_OS_IPHONE
    glBindVertexArrayOES(0);
#else
    glBindVertexArray(0);
#endif
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
    glBufferData(GL_ARRAY_BUFFER, sizeof(LevelVertexAttribs)*self.vertexCount, self.vertices, GL_STREAM_DRAW);
    
    GL_DEBUG_GENERAL;
    
    return bufferName;
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

@end
