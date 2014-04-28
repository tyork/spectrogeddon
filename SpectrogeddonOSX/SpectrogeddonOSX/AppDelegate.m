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

// TODO: refactor

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
        self.spectrumGenerator = [[SpectrumGenerator alloc] init];
        self.spectrumGenerator.delegate = self;
    }
    if(!self.colorMaps)
    {
        self.colorMaps = [[ColorMapSet alloc] init];
        self.glView.colorMapImage = [self.colorMaps nextColorMap];
    }
    
    [self updateSourceMenu];
    
    const CVReturn error = CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
    if(error != kCVReturnSuccess)
    {
        DLOG(@"Failed to init display link with error %d", error);
    }
    CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkCallback, (__bridge void*)self);
    CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, self.glView.openGLContext.CGLContextObj, self.glView.pixelFormat.CGLPixelFormatObj);

    [self resume];
}

- (void)updateSourceMenu
{
    [self.sourceMenu removeAllItems];
    
    NSDictionary* sources = [SpectrumGenerator availableSources];
    NSString* currentSourceID = self.spectrumGenerator.preferredSourceID;
    [sources enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:key action:@selector(didPickSource:) keyEquivalent:@""];
        [item setState:([currentSourceID isEqualToString:obj] ? NSOnState : NSOffState)];
        [item setRepresentedObject:obj];
        [self.sourceMenu addItem:item];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    CVDisplayLinkRelease(_displayLink);
}

- (void)applicationDidUnhide:(NSNotification *)notification
{
    [self resume];
}

- (void)applicationDidHide:(NSNotification *)notification
{
    [self pause];
}

- (void)pause
{
    CVDisplayLinkStop(_displayLink);
    [self.spectrumGenerator stopGenerating];
}

- (void)resume
{
    [self.spectrumGenerator startGenerating];
    CVDisplayLinkStart(_displayLink);
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

- (void)didPickSource:(NSMenuItem*)sender
{
    NSString* sourceID = [sender representedObject];
    self.spectrumGenerator.preferredSourceID = sourceID;
    [self updateSourceMenu];
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

