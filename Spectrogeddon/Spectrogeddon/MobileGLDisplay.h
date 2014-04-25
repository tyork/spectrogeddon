//
//  MobileGLDisplay.h
//  Spectrogeddon
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Random. All rights reserved.
//

#import <GLKit/GLKit.h>

@class TimeSequence;

@interface MobileGLDisplay : NSObject <GLKViewDelegate>

@property (nonatomic,weak) GLKView* glView;

@property (nonatomic,strong) UIImage* colorMapImage;

- (void)redisplay;

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence;

@end
