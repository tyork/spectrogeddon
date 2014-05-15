//
//  RadialScrollingRenderer.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 13/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "RadialScrollingRenderer.h"
#import <GLKit/GLKit.h>
#import "ShadedMesh.h"

static NSUInteger const NumberOfSpokes = 48;
static NSUInteger const NumberOfVerticesPerSpoke = 4;
static NSUInteger const NumberOfBufferVertices = (NumberOfSpokes + 1) * NumberOfVerticesPerSpoke;

@interface RadialScrollingRenderer ()
@property (nonatomic,strong) ShadedMesh* shadedMesh;
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
        [self.shadedMesh updateVertices:^(TexturedVertexAttribs *const vertices) {
            [self initializeVertices:vertices];
        }];
    }
}

- (ShadedMesh*)shadedMesh
{
    if(!_shadedMesh)
    {
        _shadedMesh = [[ShadedMesh alloc] initWithNumberOfVertices:NumberOfBufferVertices];
        [_shadedMesh updateVertices:^(TexturedVertexAttribs *const vertices) {
            [self initializeVertices:vertices];
        }];
    }
    return _shadedMesh;
}

- (void)render
{
    [self.shadedMesh updateVertices:^(TexturedVertexAttribs *const vertices) {
        
        const float offset = (self.activeScrollingDirectionIndex == 0) ? self.scrollingPosition : (1.0f - self.scrollingPosition);
        const float contraOffset = 1.0f - offset;
        const float edgeV = self.scrollingPosition;
        const NSUInteger stripOffset = NumberOfBufferVertices/2;
        for(NSUInteger spokeIndex = 0; spokeIndex <= NumberOfSpokes; spokeIndex++)
        {
            const NSUInteger innerVertexIndex = spokeIndex * 2; // 2 points per strip
            const NSUInteger outerVertexIndex = innerVertexIndex + stripOffset + 1;
            vertices[innerVertexIndex].s = vertices[outerVertexIndex].s = edgeV;
            vertices[innerVertexIndex+1].x = vertices[outerVertexIndex-1].x = offset * vertices[innerVertexIndex].x + contraOffset * vertices[outerVertexIndex].x;
            vertices[innerVertexIndex+1].y = vertices[outerVertexIndex-1].y = offset * vertices[innerVertexIndex].y + contraOffset * vertices[outerVertexIndex].y;
        }
    }];
    [self.shadedMesh render];
}

#pragma mark - Helpers -

- (void)initializeVertices:(TexturedVertexAttribs* const)vertices
{
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
        vertices[innerVertexIndex] = (TexturedVertexAttribs) { position.x*innerRadius, position.y*innerRadius, edgeV, fractionOfEdges };
        vertices[innerVertexIndex+1] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, 1.0f - edgeV, fractionOfEdges };
        vertices[outerVertexIndex-1] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, edgeV, fractionOfEdges };
        vertices[outerVertexIndex] = (TexturedVertexAttribs) { position.x*outerRadius, position.y*outerRadius, edgeV, fractionOfEdges };
    }
}


@end
