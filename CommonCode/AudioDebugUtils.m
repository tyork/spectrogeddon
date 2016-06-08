//
//  AudioDebugUtils.m
//  SpectrogeddonOSX
//
//  Created by Tom York on 20/04/2015.
//  Copyright (c) 2015 Spectrogeddon. All rights reserved.
//

#import "AudioDebugUtils.h"

void DLOGTime()
{
#ifndef NDEBUG
    mach_timebase_info_data_t timebaseInfo = {0, 0};
    mach_timebase_info(&timebaseInfo);
    const uint64_t timeInAbs = mach_absolute_time();
    const uint64_t timeInNanoseconds = (timebaseInfo.numer == 1 && timebaseInfo.denom == 1) ? timeInAbs : (timebaseInfo.numer * timeInAbs / timebaseInfo.denom);
    NSLog(@"%@", @(timeInNanoseconds));

#endif
}

void DLOGEventOnThread(NSString* event)
{
#ifndef NDEBUG
    const NSUInteger threadHash = [[NSThread currentThread] hash];
    NSLog(@"%@: %@", event, @(threadHash));
    
#endif
}

