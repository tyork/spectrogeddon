//
//  AudioSource.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import <Foundation/Foundation.h>

@class TimeSequence;

typedef void(^AudioSourceNotificationBlock)(TimeSequence* capturedAudio);

/**
 Abstract class representing a source of audio.
 */
@interface AudioSource : NSObject

@property (nonatomic,strong,readonly) dispatch_queue_t notificationQueue;
@property (nonatomic,copy,readonly) AudioSourceNotificationBlock notificationBlock;

- (id)initWithNotificationQueue:(dispatch_queue_t)queue block:(AudioSourceNotificationBlock)block;

- (void)startCapturing;

- (void)stopCapturing;

@end
