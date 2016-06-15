//
//  ShadedMesh.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 15/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;
@import GLKit;
#import "RendererTypes.h"

typedef void(^VertexGenerator)(TexturedVertexAttribs* const vertices);

@interface ShadedMesh : NSObject

@property (nonatomic,readonly) NSUInteger numberOfVertices;
@property (nonatomic) GLKMatrix4 transform;

- (instancetype)initWithNumberOfVertices:(NSUInteger)vertexCount;

- (void)resizeMesh:(NSUInteger)changedVertexCount;

- (void)updateVertices:(VertexGenerator)generator;

- (void)render;

@end
