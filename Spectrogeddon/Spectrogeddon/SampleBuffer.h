//
//  SampleRingBuffer.h
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

#import <Foundation/Foundation.h>

@class TimeSequence;

/**
 Stores raw samples so as to retain the newest ones when overfilled.
 Allows easy retrieval of samples as a time sequence.
 */
@interface SampleBuffer : NSObject

@property (nonatomic,readonly) BOOL hasOutput;

- (id)initWithBufferSize:(NSUInteger)sampleCount;   // TODO: enforce power of two.

- (void)writeSamples:(SInt16*)samples count:(NSUInteger)count timeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration;  //!< Note that samples are passed in as SInt16.

- (TimeSequence*)readOutputSamples; //!< Note that samples are retrieved as a float array wrapped by TimeSequence.

@end
