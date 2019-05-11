//
//  LoggingUtilities.h
//  Spectrogeddon
//
//  Created by Tom York on 16/06/2016.
//  Copyright © 2016 Random. All rights reserved.
//

@import Foundation;

#ifdef NDEBUG
#define DLOG(...)
#else
#define DLOG(...) NSLog(__VA_ARGS__)
#endif

void DLOGTime(void);

void DLOGEventTime(NSString* event);

void DLOGEventOnThread(NSString* event);
