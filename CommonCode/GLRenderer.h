//
//  GLRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RendererTypes.h"

@class DisplaySettings;

@interface GLRenderer : NSObject

@property (nonatomic) RenderSize renderSize;

- (void)addMeasurementsForDisplay:(NSArray*)channels;

- (void)render;

- (void)useDisplaySettings:(DisplaySettings*)displaySettings;

@end
