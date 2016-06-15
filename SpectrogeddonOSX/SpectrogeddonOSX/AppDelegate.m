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
    [self updateSharpnessMenu];
    [self updateDisplayMenu];
    [self updateScrollingDirectionsMenu];

    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
    [self resume];
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

#pragma - Actions -

- (IBAction)nextColorMap:(id)sender
{
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings* settings) {
        settings.colorMap = [self.colorMaps nextColorMap];
        return settings;
    }];
    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
}

- (IBAction)changeFrequencyScale:(id)sender
{
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings* settings) {
        settings.useLogFrequencyScale = !settings.useLogFrequencyScale;
        return settings;
    }];
    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
    [self updateDisplayMenu];
}

- (void)didPickScrollDirection:(id)sender
{
    NSNumber* scrollingDirection = [sender representedObject];
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings* settings) {
        settings.scrollingDirectionIndex = [scrollingDirection unsignedIntegerValue];
        return settings;
    }];
    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
    [self updateScrollingDirectionsMenu];
}

- (void)didPickSpeed:(id)sender
{
    NSNumber* speed = [sender representedObject];
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
        settings.scrollingSpeed = [speed integerValue];
        return settings;
    }];
    [self.glView useDisplaySettings:[self.settingsStore displaySettings]];
    [self updateSpeedMenu];
}

- (void)didPickSharpness:(id)sender
{
    NSNumber* sharpness = [sender representedObject];
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
        settings.sharpness = [sharpness integerValue];
        return settings;
    }];
    self.spectrumGenerator.bufferSizeDivider = [sharpness integerValue];
    [self updateSharpnessMenu];
}

- (void)didPickSource:(NSMenuItem*)sender
{
    NSString* sourceID = [sender representedObject];
    self.spectrumGenerator.preferredSourceID = sourceID;
    [self updateSourceMenu];
}

#pragma mark - Menu updates -

- (void)updateSpeedMenu
{
    [self.speedMenu removeAllItems];
    
    NSNumber* currentSpeed = @([self.settingsStore displaySettings].scrollingSpeed);
    NSArray* speeds = @[ @1, @2, @4, @8 ];
    [speeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        // TODO: this conversion of the number directly into a keyEquivalent is hacky and will break beyond 9x (e.g. 16x -> "16" which is not a valid key
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@x", obj] action:@selector(didPickSpeed:) keyEquivalent:[obj stringValue]];
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

- (void)updateScrollingDirectionsMenu
{
    [self.scrollingDirectionsMenu removeAllItems];
    
    NSArray* names = [self.glView namesForSupportedScrollingDirections];
    [names enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* charCode = [obj length] > 0 ? [[obj substringToIndex:1] lowercaseString] : @"";
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:obj action:@selector(didPickScrollDirection:) keyEquivalent:charCode];
        [item setKeyEquivalentModifierMask:0];
        [item setState:(self.settingsStore.displaySettings.scrollingDirectionIndex == idx) ? NSOnState : NSOffState];
        [item setRepresentedObject:@(idx)];
        [self.scrollingDirectionsMenu addItem:item];
    }];
}

- (void)updateDisplayMenu
{
    self.stretchFrequenciesMenuItem.state = self.settingsStore.displaySettings.useLogFrequencyScale ? NSOnState : NSOffState;
}

- (void)updateSharpnessMenu
{
    [self.sharpnessMenu removeAllItems];
    
    NSNumber* currentSharpness = @(self.settingsStore.displaySettings.sharpness);
    NSArray* sharpnessValues = @[ @4, @2, @1 ];
    [sharpnessValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@x", obj] action:@selector(didPickSharpness:) keyEquivalent:@""];
        [item setState:[obj isEqualToNumber:currentSharpness]];
        [item setRepresentedObject:obj];
        [self.sharpnessMenu addItem:item];
    }];
}

#pragma mark - Spectrum generator -

- (void)spectrumGenerator:(SpectrumGenerator *)generator didGenerateSpectrums:(NSArray *)spectrums
{
    [self.glView addMeasurementsToDisplayQueue:spectrums];
}

@end

