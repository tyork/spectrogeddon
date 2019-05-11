//
//  GLRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;
#import "RendererTypes.h"

@class DisplaySettings;
@class TimeSequence;

NS_ASSUME_NONNULL_BEGIN

@interface GLRenderer : NSObject

@property (nonatomic) RenderSize renderSize;

- (void)addMeasurementsForDisplay:(NSArray<TimeSequence*>*)channels;

- (void)render;

- (void)useDisplaySettings:(DisplaySettings*)displaySettings;

- (NSArray<NSString*>*)namesForScrollingDirections;

@end

NS_ASSUME_NONNULL_END
