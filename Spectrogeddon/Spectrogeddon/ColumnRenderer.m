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
@property (nonatomic) GLint levelAttribute;
@property (nonatomic) GLint transformUniform;
@property (nonatomic) GLint positionAttribute;

@property (nonatomic) GLuint mesh;
@property (nonatomic) NSTimeInterval originTime;
@property (nonatomic) NSTimeInterval lastDisplayedTime;
@property (nonatomic) GLKMatrix4 transform;
@property (nonatomic) LevelVertexAttribs* vertices;
@property (nonatomic) GLsizei vertexCount;
@end


@implementation ColumnRenderer

- (void)dealloc
{
    glDeleteProgram(_shader);
    glDeleteBuffers(1, &_mesh);
    free(_vertices);
}

- (void)setColorMapImage:(UIImage *)colorMapImage
{
    if(_colorMapImage != colorMapImage)
    {
        _colorMapImage = colorMapImage;
        self.texture = nil;
    }
}

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence
{
    if(!timeSequence.numberOfValues)
    {
        return;
    }
    
    const GLsizei vertexCountForSequence = (GLsizei)(timeSequence.numberOfValues * 2);
    const BOOL isFirstUse = self.vertexCount != vertexCountForSequence;
    if(isFirstUse)
    {
        free(self.vertices);
        self.vertexCount = vertexCountForSequence;
        self.vertices = (LevelVertexAttribs*)calloc(self.vertexCount, sizeof(LevelVertexAttribs));

        for(NSUInteger valueIndex = 0; valueIndex < timeSequence.numberOfValues; valueIndex++)
        {
            const NSUInteger vertexIndex = valueIndex << 1;
            const float y = (float)valueIndex;
            self.vertices[vertexIndex] = (LevelVertexAttribs){ 0.0f, y, 0.0f };
            self.vertices[vertexIndex+1] = (LevelVertexAttribs){ 1.0f, y, 0.0f };
        }
    }
    
    if(!self.originTime)
    {
        self.originTime = timeSequence.timeStamp;
        self.lastDisplayedTime = timeSequence.timeStamp;
    }
    
    float x = 1.0f - self.scrollingSpeed * (self.lastDisplayedTime - self.originTime);
    if(x < -1.0f)
    {
        self.originTime = self.lastDisplayedTime;
        x = 1.0f;
    }
    
    const GLKMatrix4 translation = GLKMatrix4MakeTranslation(x, -1.0f, 0.0f);
    self.transform = GLKMatrix4Scale(translation, self.scrollingSpeed * timeSequence.duration, 2.0f/(float)(timeSequence.numberOfValues - 1), 1.0f);
    
    for(NSUInteger valueIndex = 0; valueIndex < timeSequence.numberOfValues; valueIndex++)
    {
        const NSUInteger vertexIndex = valueIndex << 1;
        const float value = [timeSequence valueAtIndex:valueIndex];
        self.vertices[vertexIndex].level = value;
        self.vertices[vertexIndex+1].level = value;
    }
    self.lastDisplayedTime = self.lastDisplayedTime + timeSequence.duration;
}

- (void)render
{
    if(!self.texture && self.colorMapImage)
    {
        self.texture = [GLKTextureLoader textureWithCGImage:self.colorMapImage.CGImage options:nil error:nil];
    }
    if(!self.shader)
    {
        self.shader = [RendererUtils loadShaderProgramNamed:@"ColumnShader"];
        self.levelTextureSampler = glGetUniformLocation(self.shader, "uLevelSampler");
        self.positionAttribute = glGetAttribLocation(self.shader, "aPosition");
        self.levelAttribute = glGetAttribLocation(self.shader, "aLevel");
        self.transformUniform = glGetUniformLocation(self.shader, "uTransform");
    }
    
    self.mesh = [self generateMeshUsingBufferName:self.mesh];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    glUseProgram(self.shader);
    glUniform1i(self.levelTextureSampler, 0);
    glUniformMatrix4fv(self.transformUniform, 1, GL_FALSE, self.transform.m);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.mesh);
    glVertexAttribPointer(self.positionAttribute, 2, GL_FLOAT, GL_FALSE, sizeof(LevelVertexAttribs), (void *)offsetof(LevelVertexAttribs, x));
    glVertexAttribPointer(self.levelAttribute, 1, GL_FLOAT, GL_FALSE, sizeof(LevelVertexAttribs), (void *)offsetof(LevelVertexAttribs, level));
    glEnableVertexAttribArray(self.positionAttribute);
    glEnableVertexAttribArray(self.levelAttribute);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, self.vertexCount);
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

@end
