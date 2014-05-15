//
//  ShadedMesh.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 15/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererTypes.h"
#import <GLKit/GLKit.h>

typedef void(^VertexGenerator)(TexturedVertexAttribs* const vertices);

@interface ShadedMesh : NSObject

@property (nonatomic) GLKMatrix4 transform;

- (instancetype)initWithNumberOfVertices:(NSUInteger)vertexCount vertexGenerator:(VertexGenerator)generator;

- (void)resizeMesh:(NSUInteger)changedVertexCount;

- (void)updateVertices:(VertexGenerator)generator;

- (void)render;

@end
