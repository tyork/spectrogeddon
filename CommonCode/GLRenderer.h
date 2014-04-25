//
//  GLRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TimeSequence;

@interface GLRenderer : NSObject

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence viewportWidth:(GLint)width height:(GLint)height;

- (void)renderFrame;

- (void)useColorMap:(CGImageRef)colorMap;

@end
