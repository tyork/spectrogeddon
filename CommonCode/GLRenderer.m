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
#import "DisplaySettings.h"
#import "ColorMap.h"

static const float SamplingRate = 44100.0f;
static const float SamplesPerBuffer = 1024.0f;
static const float ScrollingConversionFactor = SamplingRate/SamplesPerBuffer;

@interface GLRenderer ()
@property (nonatomic,strong) ColumnRenderer* channel1Renderer;
@property (nonatomic,strong) ColumnRenderer* channel2Renderer;
@property (nonatomic,strong) ScrollingRenderer* scrollingRenderer;

@property (nonatomic) NSTimeInterval frameOriginTime;
@property (nonatomic) NSTimeInterval lastRenderedSampleTime;
@property (nonatomic,strong) DisplaySettings* displaySettings;
@end

@implementation GLRenderer

- (instancetype)init
{
    if((self = [super init]))
    {
        _scrollingRenderer = [[ScrollingRenderer alloc] init];
        _channel1Renderer = [[ColumnRenderer alloc] init];
        _channel2Renderer = [[ColumnRenderer alloc] init];
    }
    return self;
}

- (void)setRenderSize:(RenderSize)renderSize
{
    if(!RenderSizeEqualToSize(renderSize, _renderSize))
    {
        _renderSize = renderSize;
        self.frameOriginTime = 0;
        self.scrollingRenderer.renderSize = renderSize;
    }
}

- (void)render
{
    if(RenderSizeIsEmpty(self.renderSize) || !self.displaySettings)
    {
        return;
    }
    
    const NSTimeInterval nowTime = CACurrentMediaTime();
    if(!self.frameOriginTime)
    {
        self.frameOriginTime = nowTime;
    }
    
    float position = [self widthFromTimeInterval:nowTime - self.frameOriginTime];
    if(position > 1.0f)
    {
        self.frameOriginTime = nowTime;
        position = 0.0f;
    }
    self.scrollingRenderer.currentPosition = position;
    
    glViewport(0, 0, self.renderSize.width, self.renderSize.height);
    glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.scrollingRenderer render];
    
    GL_DEBUG_GENERAL;
}

- (void)addMeasurementsForDisplay:(NSArray*)spectrums
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
        self.channel1Renderer.positioning = GLKMatrix4Identity;
        [self updateChannelRenderer:self.channel1Renderer withSequence:[spectrums firstObject]];
    }
    id __weak weakSelf = self;
    [self.scrollingRenderer drawWithCommands:^{
        
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

- (void)useDisplaySettings:(DisplaySettings *)displaySettings
{
    self.displaySettings = displaySettings;
    self.channel1Renderer.colorMapImage = [displaySettings.colorMap imageRef];
    self.channel2Renderer.colorMapImage = [displaySettings.colorMap imageRef];
}

- (void)updateChannelRenderer:(ColumnRenderer*)renderer withSequence:(TimeSequence*)timeSequence
{
    float baseOffset = [self widthFromTimeInterval:(timeSequence.timeStamp - self.frameOriginTime)];
    if(baseOffset > 1.0f)
    {
        baseOffset = 0.0f;
    }
    
    const float width = [self widthFromTimeInterval:timeSequence.duration + timeSequence.timeStamp - self.lastRenderedSampleTime];
    [renderer updateVerticesForTimeSequence:timeSequence offset:(2.0f * baseOffset - 1.0f) width:width];
}

- (float)widthFromTimeInterval:(NSTimeInterval)timeInterval
{
    const float screenFractionPerSecond = self.displaySettings.scrollingSpeed*ScrollingConversionFactor/(float)self.renderSize.width;
    return screenFractionPerSecond * timeInterval;
}

@end
