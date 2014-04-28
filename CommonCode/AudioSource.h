//
//  AudioSource.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

#import <Foundation/Foundation.h>

/**
 @param capturedChannels An array of @ref TimeSequence objects.
 */
typedef void(^AudioSourceNotificationBlock)(NSArray* capturedChannels);

/**
 A source of audio.
 */
@interface AudioSource : NSObject

@property (nonatomic,strong,readonly) dispatch_queue_t notificationQueue;
@property (nonatomic,copy,readonly) AudioSourceNotificationBlock notificationBlock;
@property (nonatomic,copy) NSString* preferredAudioSourceID;

+ (void)requestPermissionToUseAudio:(void(^)(BOOL isAllowed))permissionBlock;

+ (NSDictionary*)availableAudioSources; // Localized name -> audio source ID pairs

- (id)initWithNotificationQueue:(dispatch_queue_t)queue block:(AudioSourceNotificationBlock)block;

- (void)startCapturing;

- (void)stopCapturing;

@end
