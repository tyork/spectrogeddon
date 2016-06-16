//
//  SettingsStore.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;

@class DisplaySettings;

@interface SettingsStore : NSObject

- (DisplaySettings*)displaySettings;

- (void)applyUpdateToSettings:(DisplaySettings*(^)(DisplaySettings*))updateBlock;

@end
