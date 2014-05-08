//
//  SettingsStore.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import "SettingsStore.h"
#import "DisplaySettings.h"

static NSString* const StoreFileName = @"Spectrogeddon.settings";

@interface SettingsStore ()
@property (nonatomic,strong) DisplaySettings* storedDisplaySettings;
@end

@implementation SettingsStore

+ (NSString*)pathToStore
{
    NSArray* directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [directories.firstObject stringByAppendingPathComponent:StoreFileName];
}

- (id)init
{
    if((self = [super init]))
    {
        [self loadDisplaySettings];
        if(!_storedDisplaySettings)
        {
            _storedDisplaySettings = [[DisplaySettings alloc] init];
        }
    }
    return self;
}

- (DisplaySettings*)displaySettings
{
    return self.storedDisplaySettings;
}

- (void)applyUpdateToSettings:(DisplaySettings*(^)(DisplaySettings*))updateBlock
{
    NSParameterAssert(updateBlock);
    self.storedDisplaySettings = updateBlock([self displaySettings]);
    [self saveDisplaySettings];
}

- (void)loadDisplaySettings
{
    self.storedDisplaySettings = [NSKeyedUnarchiver unarchiveObjectWithFile:[SettingsStore pathToStore]];
}

- (void)saveDisplaySettings
{
    [NSKeyedArchiver archiveRootObject:self.storedDisplaySettings toFile:[SettingsStore pathToStore]];
}

@end
