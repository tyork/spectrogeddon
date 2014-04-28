//
//  AppDelegate.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 25/04/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "AppDelegate.h"
#import "DesktopOpenGLView.h"
#import "SpectrumGenerator.h"
#import "ColorMapSet.h"
#import "MicAudioSource.h"

@interface AppDelegate ()  <SpectrumGeneratorDelegate>
@property (nonatomic,strong) SpectrumGenerator* spectrumGenerator;
@property (nonatomic,strong) ColorMapSet* colorMaps;
@end

@implementation AppDelegate
{
    CVDisplayLinkRef _displayLink;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if(!self.spectrumGenerator)
    {
        self.spectrumGenerator = [[SpectrumGenerator alloc] initWithAudioSourceClass:[MicAudioSource class]];
        self.spectrumGenerator.delegate = self;
    }
    if(!self.colorMaps)
    {
        self.colorMaps = [[ColorMapSet alloc] init];
        self.glView.colorMapImage = [self.colorMaps nextColorMap];
    }
    
    const CVReturn error = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    if(error != kCVReturnSuccess)
    {
        DLOG(@"Failed to init display link with error %d", error);
    }
    CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkCallback, (__bridge void*)self);
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, self.glView.openGLContext.CGLContextObj, self.glView.pixelFormat.CGLPixelFormatObj);
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    CVDisplayLinkRelease(_displayLink);
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    [self.spectrumGenerator startGenerating];
    CVDisplayLinkStart(_displayLink);
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
    CVDisplayLinkStop(_displayLink);
    [self.spectrumGenerator stopGenerating];
}

- (IBAction)nextColorMap:(id)sender
{
    NSImage* image = [self.colorMaps nextColorMap];
    [self.glView setColorMapImage:image];
}

- (void)render
{
    [self.glView redisplay];
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    @autoreleasepool {
        id target = (__bridge id)displayLinkContext;
        dispatch_async(dispatch_get_main_queue(), ^{
            [target render];
        });
    }
    return kCVReturnSuccess;
}


#pragma mark - Spectrum generator -

- (void)spectrumGenerator:(SpectrumGenerator *)generator didGenerateSpectrum:(TimeSequence *)levels
{
    [self.glView addMeasurementToDisplayQueue:levels];
}

@end

