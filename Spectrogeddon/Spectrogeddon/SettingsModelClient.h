//
//  SettingsModelClient.h
//  Spectrogeddon
//
//  Created by Tom York on 09/02/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

@import Foundation;

@class SettingsWrapper;

NS_ASSUME_NONNULL_BEGIN

@protocol SettingsModelClient <NSObject>
@property (nonatomic,strong) SettingsWrapper* settingsModel;
@end

NS_ASSUME_NONNULL_END
