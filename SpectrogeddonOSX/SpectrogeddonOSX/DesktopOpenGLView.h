//
//  DesktopOpenGLView.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Cocoa;

@class TimeSequence;
@class DisplaySettings;

NS_ASSUME_NONNULL_BEGIN

@interface DesktopOpenGLView : NSOpenGLView

- (void)useDisplaySettings:(DisplaySettings*)displaySettings;

- (void)addMeasurementsToDisplayQueue:(NSArray<TimeSequence*>*)spectrums;

- (void)pauseRendering;

- (void)resumeRendering;

- (NSArray<NSString*>*)namesForSupportedScrollingDirections;

@end

NS_ASSUME_NONNULL_END
