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
#import "SettingsStore.h"
#import "DisplaySettings.h"

@interface AppDelegate ()  <SpectrumGeneratorDelegate>
@property (nonatomic,strong) SpectrumGenerator* spectrumGenerator;
@property (nonatomic,strong) ColorMapSet* colorMaps;
@property (nonatomic,strong) SettingsStore* settingsStore;
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
    }
    
    self.settingsStore = [[SettingsStore alloc] init];
    if(![self.settingsStore displaySettings].colorMap)
    {
        [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
            settings.colorMap = [self.colorMaps currentColorMap];
            return settings;
        }];
    }
    
    [self updateSourceMenu];
    [self updateSpeedMenu];

    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
    [self resume];
}

- (void)updateSpeedMenu
{
    [self.speedMenu removeAllItems];
    
    NSNumber* currentSpeed = @([self.settingsStore displaySettings].scrollingSpeed);
    NSArray* speeds = @[ @1, @2, @4 ];
    [speeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@x", obj] action:@selector(didTapSpeed:) keyEquivalent:@""];
        [item setState:[obj isEqualToNumber:currentSpeed]];
        [item setRepresentedObject:obj];
        [self.speedMenu addItem:item];
    }];
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
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings* settings) {
        settings.colorMap = [self.colorMaps nextColorMap];
        return settings;
    }];
    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
}

- (void)didTapSpeed:(id)sender
{
    NSNumber* speed = [sender representedObject];
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
        settings.scrollingSpeed = [speed integerValue];
        return settings;
    }];
    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
    [self updateSpeedMenu];
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

