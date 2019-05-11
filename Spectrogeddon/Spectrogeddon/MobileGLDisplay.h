//
//  MobileGLDisplay.h
//  Spectrogeddon
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Random. All rights reserved.
//

#import <GLKit/GLKit.h>

@class TimeSequence;
@class DisplaySettings;

NS_ASSUME_NONNULL_BEGIN

@interface MobileGLDisplay : NSObject <GLKViewDelegate>

@property (nonatomic,weak) GLKView* glView;

- (void)useDisplaySettings:(DisplaySettings*)displaySettings;

- (void)redisplay;

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence;

@end

NS_ASSUME_NONNULL_END
