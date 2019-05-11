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

NS_ASSUME_NONNULL_BEGIN

void DLOGTime(void);

void DLOGEventTime(NSString* _Nullable event);

void DLOGEventOnThread(NSString* _Nullable event);

NS_ASSUME_NONNULL_END
