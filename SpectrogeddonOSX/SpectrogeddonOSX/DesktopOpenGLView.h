//
//  DesktopOpenGLView.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TimeSequence;
@class DisplaySettings;

@interface DesktopOpenGLView : NSOpenGLView

- (void)useDisplaySettings:(DisplaySettings*)displaySettings;

- (void)addMeasurementsToDisplayQueue:(NSArray*)spectrums;

- (void)pauseRendering;

- (void)resumeRendering;

- (NSArray*)namesForSupportedScrollingDirections;

@end
