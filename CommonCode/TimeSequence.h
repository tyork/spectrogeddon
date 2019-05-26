//
//  TimeSequence.h
//  Spectrogeddon
//
//  Created by Tom York on 18/11/2013.
//  
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface TimeSequence : NSObject

@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) NSTimeInterval duration;

- (id)initWithNumberOfValues:(NSUInteger)count values:(float*)values;

- (NSUInteger)numberOfValues;

- (float)valueAtIndex:(NSUInteger)valueIndex;

- (float*)rawValues;

- (void)appendTimeSequence:(TimeSequence*)timeSequence;

@end

NS_ASSUME_NONNULL_END
