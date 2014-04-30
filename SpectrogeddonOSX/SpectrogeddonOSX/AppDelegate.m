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
    [self.glView pauseRendering];
    [self.spectrumGenerator stopGenerating];
}

- (void)resume
{
    [self.glView resumeRendering];
    [self.spectrumGenerator startGenerating];
}

- (IBAction)nextColorMap:(id)sender
{
    NSImage* image = [self.colorMaps nextColorMap];
    [self.glView setColorMapImage:image];
}

- (void)didPickSource:(NSMenuItem*)sender
{
    NSString* sourceID = [sender representedObject];
    self.spectrumGenerator.preferredSourceID = sourceID;
    [self updateSourceMenu];
}

#pragma mark - Spectrum generator -

- (void)spectrumGenerator:(SpectrumGenerator *)generator didGenerateSpectrums:(NSArray *)spectrums
{
    [self.glView addMeasurementsToDisplayQueue:spectrums];
}

@end

