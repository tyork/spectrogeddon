//
//  SampleSetMesh.m
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import "ColumnRenderer.h"
#import "TimeSequence.h"
#import "ShadedMesh.h"

@interface ColumnRenderer ()
@property (nonatomic,strong) GLKTextureInfo* texture;
@property (nonatomic,strong) ShadedMesh* shadedMesh;
@property (nonatomic) BOOL invalidatedVertices;
@end


@implementation ColumnRenderer

- (void)dealloc
{
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

- (void)generateVertexPositions:(TexturedVertexAttribs* const)vertices
{
    const float logOffset = 0.001f; // Safety margin to ensure we don't try taking log2(0)
    const float logNormalization = 1.0f/log2f(logOffset);
    const float yScale = 1.0f / (float)(self.shadedMesh.numberOfVertices/2 - 1);
    for(NSUInteger valueIndex = 0; valueIndex < self.shadedMesh.numberOfVertices/2; valueIndex++)
    {
        const NSUInteger vertexIndex = valueIndex << 1;
        const float y = self.useLogFrequencyScale ? (1.0f-logNormalization*log2f((float)valueIndex*yScale+logOffset)) : (float)valueIndex * yScale;
        vertices[vertexIndex] = (TexturedVertexAttribs){ 0.0f, y, 0.0f, 0.0f };
        vertices[vertexIndex+1] = (TexturedVertexAttribs){ 1.0f, y, 0.0f, 0.0f };
    }
}

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence offset:(float)offset width:(float)width
{
    if(!timeSequence.numberOfValues)
    {
        return;
    }
    
    const GLsizei vertexCountForSequence = (GLsizei)(timeSequence.numberOfValues * 2);
    if(!self.shadedMesh)
    {
        self.shadedMesh = [[ShadedMesh alloc] initWithNumberOfVertices:vertexCountForSequence];
        self.invalidatedVertices = YES;
    }
    else if(self.shadedMesh.numberOfVertices != vertexCountForSequence)
    {
        [self.shadedMesh resizeMesh:vertexCountForSequence];
        self.invalidatedVertices = YES;
    }
    
    if(self.invalidatedVertices)
    {
        [self.shadedMesh updateVertices:^(TexturedVertexAttribs *const vertices) {
            [self generateVertexPositions:vertices];
        }];
        self.invalidatedVertices = NO;
    }

    [self.shadedMesh updateVertices:^(TexturedVertexAttribs *const vertices) {
        for(NSUInteger valueIndex = 0; valueIndex < timeSequence.numberOfValues; valueIndex++)
        {
            const NSUInteger vertexIndex = valueIndex << 1;
            const float value = [timeSequence valueAtIndex:valueIndex];
            vertices[vertexIndex].t = value;
            vertices[vertexIndex+1].t = value;
        }
    }];

    const GLKMatrix4 translation = GLKMatrix4MakeTranslation(offset, 0.0f, 0.0f);
    self.shadedMesh.transform = GLKMatrix4Multiply(GLKMatrix4Scale(translation, width, 1.0f, 1.0f), self.positioning);
}

- (void)render
{
    if(!self.colorMapImage || !self.shadedMesh)
    {
        return;
    }
    
    if(!self.texture && self.colorMapImage)
    {
        self.texture = [GLKTextureLoader textureWithCGImage:self.colorMapImage options:nil error:nil];
    }
    
    glBindTexture(GL_TEXTURE_2D, self.texture.name);
    [self.shadedMesh render];
    glBindTexture(GL_TEXTURE_2D, 0);
}

@end
