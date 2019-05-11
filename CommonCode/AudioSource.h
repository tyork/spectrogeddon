//
//  AudioSource.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

@import Foundation;

@class TimeSequence;

NS_ASSUME_NONNULL_BEGIN

/**
 @param capturedChannels An array of @ref TimeSequence objects.
 */
typedef void(^AudioSourceNotificationBlock)(NSArray<TimeSequence*>* capturedChannels);

/**
 A source of audio.
 */
@interface AudioSource : NSObject

@property (nonatomic,strong,readonly) dispatch_queue_t notificationQueue;
@property (nonatomic,copy,readonly) AudioSourceNotificationBlock notificationBlock;

@property (nonatomic,copy) NSString* preferredAudioSourceID;
@property (nonatomic) NSUInteger bufferSizeDivider;

+ (void)requestPermissionToUseAudio:(void(^)(BOOL isAllowed))permissionBlock;

+ (NSDictionary<NSString*, NSString*>*)availableAudioSources; // Localized name -> audio source ID pairs

- (instancetype)initWithNotificationQueue:(dispatch_queue_t)queue block:(AudioSourceNotificationBlock)block;

- (void)startCapturing;

- (void)stopCapturing;

@end

NS_ASSUME_NONNULL_END
