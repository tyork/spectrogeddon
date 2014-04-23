//
//  AudioSource.m
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import "AudioSource.h"

@interface AudioSource ()

@end

@implementation AudioSource

- (id)initWithNotificationQueue:(dispatch_queue_t)queue block:(AudioSourceNotificationBlock)block
{
    NSParameterAssert(block);
    if((self = [super init]))
    {
        _notificationQueue = queue ?: dispatch_get_main_queue();
        _notificationBlock = [block copy];
    }
    return self;
}

- (void)startCapturing
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)stopCapturing
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
