//
//  ScrollingRenderer.m
//  Spectrogeddon
//
//  Created by Tom York on 17/04/2014.
//  
//

#import "LinearScrollingRenderer.h"
#import "ShadedMesh.h"

#define NumberOfBufferVertices 8

@interface LinearScrollingRenderer ()
@property (nonatomic,strong) ShadedMesh* shadedMesh;
@end

@implementation LinearScrollingRenderer

#pragma mark - ScrollingRenderer -

@synthesize scrollingPosition = _scrollingPosition;
@synthesize activeScrollingDirectionIndex = _activeScrollingDirectionIndex;

- (NSArray<NSString*>*)namesForScrollingDirections;
{
    return @[ NSLocalizedString(@"Horizontal", @""), NSLocalizedString(@"Vertical", @"") ];
}

- (RenderSize)bestRenderSizeFromSize:(RenderSize)size
{
    return (self.activeScrollingDirectionIndex == 0) ? size : (RenderSize) { size.height, size.width } ;
}

- (ShadedMesh*)shadedMesh
{
    if(!_shadedMesh)
    {
        _shadedMesh = [[ShadedMesh alloc] initWithNumberOfVertices:NumberOfBufferVertices];
        [_shadedMesh updateVertices:^(TexturedVertexAttribs *const vertices) {
            TexturedVertexAttribs bufferMesh[NumberOfBufferVertices] = {
                { -3.0f, +1.0f, 0.0f, 1.0f },
                { -3.0f, -1.0f, 0.0f, 0.0f },
                { -1.0f, +1.0f, 1.0f, 1.0f },
                { -1.0f, -1.0f, 1.0f, 0.0f },
                { -1.0f, +1.0f, 0.0f, 1.0f },
                { -1.0f, -1.0f, 0.0f, 0.0f },
                { +1.0f, +1.0f, 1.0f, 1.0f },
                { +1.0f, -1.0f, 1.0f, 0.0f }
            };
            memcpy(vertices, bufferMesh, sizeof(TexturedVertexAttribs)*NumberOfBufferVertices);
        }];
    }
    return _shadedMesh;
}

- (void)render
{
    self.shadedMesh.transform = [self transform];
    [self.shadedMesh render];
}

- (GLKMatrix4)transform
{
    const float translation = 2.0f * (1.0f - self.scrollingPosition);
    const GLKMatrix4 rotation = (self.activeScrollingDirectionIndex == 0) ? GLKMatrix4Identity : GLKMatrix4MakeRotation(-M_PI_2, 0.0f, 0.0f, 1.0f);
    return GLKMatrix4Multiply(rotation, GLKMatrix4MakeTranslation(translation, 0.0f, 0.0f));
}

@end
