//
//  GLRenderer.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "GLRenderer.h"
#import "RendererDefs.h"
#import "ScrollingRenderer.h"
#import "ColumnRenderer.h"
#import "TimeSequence.h"

static const float DefaultScrollingSpeed = 0.35f;  // Screen fraction per second

@interface GLRenderer ()
@property (nonatomic,strong) ColumnRenderer* columnRenderer;
@property (nonatomic,strong) ScrollingRenderer* scrollingRenderer;

@property (nonatomic) NSTimeInterval frameOriginTime;
@property (nonatomic) NSTimeInterval lastRenderedSampleTime;
@property (nonatomic) float scrollingSpeed;
@end

@implementation GLRenderer

- (instancetype)init
{
    if((self = [super init]))
    {
        _scrollingSpeed = DefaultScrollingSpeed;
        _scrollingRenderer = [[ScrollingRenderer alloc] init];
        _columnRenderer = [[ColumnRenderer alloc] init];
    }
    return self;
}

- (void)renderFrame
{
    const NSTimeInterval nowTime = CACurrentMediaTime();
    if(!self.frameOriginTime)
    {
        self.frameOriginTime = nowTime;
    }
    
    float position = [self widthFromTimeInterval:nowTime - self.frameOriginTime];
    if(position > 1.0f)
    {
        self.frameOriginTime = nowTime;
        position -= floorf(position);
    }
    self.scrollingRenderer.currentPosition = position;
    
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.scrollingRenderer render];
    
    GL_DEBUG_GENERAL;
}

- (void)addMeasurementToDisplayQueue:(TimeSequence*)timeSequence viewportWidth:(GLint)width height:(GLint)height
{
    [self updateColumnWithSequence:timeSequence];
    id __weak weakSelf = self;
    [self.scrollingRenderer drawContentWithWidth:width height:height commands:^{
        
        GLRenderer* strongSelf = weakSelf;
        if(strongSelf)
        {
            [strongSelf.columnRenderer render];
            self.lastRenderedSampleTime = timeSequence.timeStamp;
        }
    }];
}

- (void)useColorMap:(CGImageRef)colorMap
{
    self.columnRenderer.colorMapImage = colorMap;
}

- (void)updateColumnWithSequence:(TimeSequence*)timeSequence
{
    float baseOffset = [self widthFromTimeInterval:(timeSequence.timeStamp - self.frameOriginTime)];
    if(baseOffset > 1.0f)
    {
        baseOffset -= floorf(baseOffset);
    }
    
    const float width = [self widthFromTimeInterval:timeSequence.duration + timeSequence.timeStamp - self.lastRenderedSampleTime];
    [self.columnRenderer updateVerticesForTimeSequence:timeSequence offset:(2.0f * baseOffset - 1.0f) width:width];
}

- (float)widthFromTimeInterval:(NSTimeInterval)timeInterval
{
    return self.scrollingSpeed * timeInterval;
}

@end
