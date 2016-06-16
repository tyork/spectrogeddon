//
//  SettingsModelClient.h
//  Spectrogeddon
//
//  Created by Tom York on 09/02/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

@import Foundation;

@class SettingsWrapper;

@protocol SettingsModelClient <NSObject>
@property (nonatomic,strong) SettingsWrapper* settingsModel;
@end
