//
//  SampleRingBuffer.h
//  Spectrogeddon
//
//  Created by Tom York on 15/04/2014.
//  
//

@import Foundation;

@class TimeSequence;

NS_ASSUME_NONNULL_BEGIN

/**
 Stores raw samples so as to retain the newest ones when overfilled.
 Allows easy retrieval of samples as a time sequence.
 */
@interface SampleBuffer : NSObject

@property (nonatomic,readonly) BOOL hasOutput;

- (instancetype)initWithBufferSize:(NSUInteger)sampleCount
                      readInterval:(NSUInteger)readInterval;   // TODO: enforce power of two.

- (void)writeNormalizedFloatSamples:(float*)samples
                              count:(NSUInteger)count
                          timeStamp:(NSTimeInterval)timeStamp
                           duration:(NSTimeInterval)duration;

- (void)writeSInt16Samples:(SInt16*)samples
                     count:(NSUInteger)count
                 timeStamp:(NSTimeInterval)timeStamp
                  duration:(NSTimeInterval)duration;

- (TimeSequence*)readOutputSamples; //!< Note that samples are retrieved as a float array wrapped by TimeSequence.

@end

NS_ASSUME_NONNULL_END
