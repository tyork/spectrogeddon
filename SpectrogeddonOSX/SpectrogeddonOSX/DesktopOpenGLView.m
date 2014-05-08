//
//  DesktopOpenGLView.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "DesktopOpenGLView.h"
#import "GLRenderer.h"
#import <OpenGL/gl3ext.h>

@interface DesktopOpenGLView ()
@property (nonatomic,strong) NSTimer* displayTimer;
@property (nonatomic,strong) GLRenderer* renderer;
@end

@implementation DesktopOpenGLView

- (void)awakeFromNib
{
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        0
    };
    
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    [self setPixelFormat:pixelFormat];
    [self setOpenGLContext:context];
}

- (void)prepareOpenGL
{
    // Ensure we sync buffer swapping
    const GLint swapInterval = 1;
    [self.openGLContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
}

- (void)resumeRendering
{
    if(!self.displayTimer)
    {
        // Create the display timer
        self.displayTimer = [NSTimer timerWithTimeInterval:0.001 target:self selector:@selector(redisplay:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.displayTimer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:self.displayTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:self.displayTimer forMode:NSModalPanelRunLoopMode];
    }
}

- (void)pauseRendering
{
    [self.displayTimer invalidate];
    self.displayTimer = nil;
}

- (GLRenderer*)renderer
{
    if(!_renderer)
    {
        _renderer = [[GLRenderer alloc] init];
    }
    return _renderer;
}

- (void)update
{
    [super update];
    self.renderer.renderSize = (RenderSize) { (GLint)self.bounds.size.width, (GLint)self.bounds.size.height };
}

- (void)redisplay:(NSTimer*)timer
{
    [self executeGL:^() {
        
        [self.renderer render];
    } flushingBuffer:YES];
}

- (void)addMeasurementsToDisplayQueue:(NSArray*)spectrums
{
    [self executeGL:^() {
        [self.renderer addMeasurementsForDisplay:spectrums];
    } flushingBuffer:NO];
}

- (void)executeGL:(void(^)(void))commands flushingBuffer:(BOOL)flushBuffer
{
    NSParameterAssert(commands);
    NSOpenGLContext* currentContext = [self openGLContext];
    [currentContext makeCurrentContext];
    CGLLockContext((CGLContextObj)[currentContext CGLContextObj]);
    commands();
    if(flushBuffer)
    {
        //    glSwapAPPLE(); // Consider swap instead.
        [currentContext flushBuffer];
    }
    CGLUnlockContext((CGLContextObj)[currentContext CGLContextObj]);
}

- (void)useDisplaySettings:(DisplaySettings*)displaySettings
{
    [self.renderer useDisplaySettings:displaySettings];
}

@end
