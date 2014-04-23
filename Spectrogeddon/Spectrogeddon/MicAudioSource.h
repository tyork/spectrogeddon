//
//  MicAudioSource.h
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

#import "AudioSource.h"

/**
 Audio sourced from the microphone.
 */
@interface MicAudioSource : AudioSource

+ (void)requestPermissionToUseAudio:(void(^)(BOOL isAllowed))permissionBlock;

@end
