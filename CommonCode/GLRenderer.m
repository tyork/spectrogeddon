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
@property (nonatomic,strong) ColumnRenderer* channel1Renderer;
@property (nonatomic,strong) ColumnRenderer* channel2Renderer;
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
        _channel1Renderer = [[ColumnRenderer alloc] init];
        _channel2Renderer = [[ColumnRenderer alloc] init];
    }
    return self;
}

- (void)renderFrameViewportWidth:(GLint)width height:(GLint)height
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
    
    glViewport(0, 0, width, height);
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.scrollingRenderer render];
    
    GL_DEBUG_GENERAL;
}

- (void)addMeasurementsToDisplayQueue:(NSArray*)spectrums viewportWidth:(GLint)width height:(GLint)height
{
    const BOOL showStereo = spectrums.count > 1;
    if(showStereo)
    {
        self.channel1Renderer.positioning = GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0f, 1.0f, 0.0f), 1.0f, 0.5f, 1.0f);
        self.channel2Renderer.positioning = GLKMatrix4Scale(GLKMatrix4MakeTranslation(0.0f, 1.0f, 0.0f), 1.0f, -0.5f, 1.0f);
        [self updateChannelRenderer:self.channel1Renderer withSequence:[spectrums firstObject]];
        [self updateChannelRenderer:self.channel2Renderer withSequence:[spectrums lastObject]];
    }
    else
    {
        _channel1Renderer.positioning = GLKMatrix4Identity;
        [self updateChannelRenderer:self.channel1Renderer withSequence:[spectrums firstObject]];
    }
    id __weak weakSelf = self;
    [self.scrollingRenderer drawContentWithWidth:width height:height commands:^{
        
        GLRenderer* strongSelf = weakSelf;
        if(strongSelf)
        {
            [strongSelf.channel1Renderer render];
            if(showStereo)
            {
                [strongSelf.channel2Renderer render];
            }
            self.lastRenderedSampleTime = [[spectrums firstObject] timeStamp];
        }
    }];
}

- (void)useColorMap:(CGImageRef)colorMap
{
    self.channel1Renderer.colorMapImage = colorMap;
    self.channel2Renderer.colorMapImage = colorMap;
}

- (void)updateChannelRenderer:(ColumnRenderer*)renderer withSequence:(TimeSequence*)timeSequence
{
    float baseOffset = [self widthFromTimeInterval:(timeSequence.timeStamp - self.frameOriginTime)];
    if(baseOffset > 1.0f)
    {
        baseOffset -= floorf(baseOffset);
    }
    
    const float width = [self widthFromTimeInterval:timeSequence.duration + timeSequence.timeStamp - self.lastRenderedSampleTime];
    [renderer updateVerticesForTimeSequence:timeSequence offset:(2.0f * baseOffset - 1.0f) width:width];
}

- (float)widthFromTimeInterval:(NSTimeInterval)timeInterval
{
    return self.scrollingSpeed * timeInterval;
}

@end
