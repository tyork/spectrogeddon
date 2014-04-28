//
//  GLRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLRenderer : NSObject

- (void)addMeasurementsToDisplayQueue:(NSArray*)channels viewportWidth:(GLint)width height:(GLint)height;

- (void)renderFrameViewportWidth:(GLint)width height:(GLint)height;

- (void)useColorMap:(CGImageRef)colorMap;

@end
