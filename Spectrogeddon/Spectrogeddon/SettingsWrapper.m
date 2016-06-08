//
//  SettingsWrapper.m
//  Spectrogeddon
//
//  Created by Tom York on 04/02/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

#import "SettingsWrapper.h"
#import "SettingsStore.h"
#import "ColorMapSet.h"
#import "DisplaySettings.h"

NSString* const kSpectroSettingsDidChangeNotification = @"SpectroSettingsDidChangeNotification";

@interface SettingsWrapper ()
@property (nonatomic,strong) SettingsStore* settingsStore;
@property (nonatomic,strong) ColorMapSet* colorMaps;
@property (nonatomic,readwrite) NSUInteger sharpness;
@end

@implementation SettingsWrapper

- (instancetype)init
{
    if((self = [super init])) {
        _sharpness = 1;
        _colorMaps = [[ColorMapSet alloc] init];
        _settingsStore = [[SettingsStore alloc] init];
        if([_settingsStore displaySettings].colorMap == nil) {
            [_settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
                settings.colorMap = [_colorMaps currentColorMap];
                return settings;
            }];
        }
    }
    return self;
}

- (void)setDisplaySettings:(DisplaySettings *)displaySettings
{
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings * oldSettings) {
        return displaySettings;
    }];
}

- (DisplaySettings*)displaySettings
{
    return [self.settingsStore displaySettings];
}

- (BOOL)isStretchingFrequency
{
    return [[self.settingsStore displaySettings] useLogFrequencyScale];
}

- (void)toggleFrequencyStretch
{
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings * settings) {
        settings.useLogFrequencyScale = !settings.useLogFrequencyScale;
        return settings;
    }];
    [self postNote];
}

- (void)nextColorMap
{
    ColorMap* newColorMap = [self.colorMaps nextColorMap];
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings * settings) {
        settings.colorMap = newColorMap;
        return settings;
    }];
    [self postNote];
}

- (void)nextScrollingSpeed
{
    NSInteger nextSpeed = 1;
    NSArray* availableSpeeds = @[ @1, @2, @4, @8 ];
    NSUInteger existingSpeedIndex = [availableSpeeds indexOfObject:@(self.displaySettings.scrollingSpeed)];
    if(existingSpeedIndex != NSNotFound) {
        nextSpeed = [availableSpeeds[(existingSpeedIndex+1)%availableSpeeds.count] integerValue];
    }
    [self.settingsStore applyUpdateToSettings:^DisplaySettings *(DisplaySettings *settings) {
        settings.scrollingSpeed = nextSpeed;
        return settings;
    }];
    [self postNote];
}

- (void)nextSharpness
{
    NSInteger nextSharpness = 1;
    NSArray* availableValues = @[ @1, @2, @4 ];
    NSUInteger existingSharpnessIndex = [availableValues indexOfObject:@(self.sharpness)];
    if(existingSharpnessIndex != NSNotFound) {
        nextSharpness = [availableValues[(existingSharpnessIndex+1)%availableValues.count] integerValue];
    }
    self.sharpness = nextSharpness;
    [self postNote];
}

- (void)postNote
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSpectroSettingsDidChangeNotification object:[self.settingsStore displaySettings] ];
}

@end
