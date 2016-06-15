//
//  SettingsWrapper.h
//  Spectrogeddon
//
//  Created by Tom York on 04/02/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kSpectroSettingsDidChangeNotification;

@class DisplaySettings;

// TODO: fold this into settings store, eventually.
// TODO: audio settings
@interface SettingsWrapper : NSObject

@property (nonatomic,strong) DisplaySettings* displaySettings;

- (void)nextColorMap;

- (void)toggleFrequencyStretch;

- (BOOL)isStretchingFrequency;

- (void)nextScrollingSpeed;

- (void)nextSharpness;

@end
