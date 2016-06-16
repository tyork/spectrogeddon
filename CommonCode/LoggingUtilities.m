//
//  LoggingUtilities.m
//  Spectrogeddon
//
//  Created by Tom York on 16/06/2016.
//  Copyright © 2016 Random. All rights reserved.
//

#import "LoggingUtilities.h"
#import <mach/mach_time.h>

void DLOGTime()
{
    DLOGEventTime(nil);
}

void DLOGEventTime(NSString* event)
{
#ifndef NDEBUG
    mach_timebase_info_data_t timebaseInfo = {0, 0};
    mach_timebase_info(&timebaseInfo);
    const uint64_t timeInAbs = mach_absolute_time();
    const uint64_t timeInNanoseconds = (timebaseInfo.numer == 1 && timebaseInfo.denom == 1) ? timeInAbs : (timebaseInfo.numer * timeInAbs / timebaseInfo.denom);
    NSLog(@"%@: %@", event, @(timeInNanoseconds));
#endif
}

void DLOGEventOnThread(NSString* event)
{
#ifndef NDEBUG
    const NSUInteger threadHash = [[NSThread currentThread] hash];
    NSLog(@"%@: %@", event, @(threadHash));
    
#endif
}
