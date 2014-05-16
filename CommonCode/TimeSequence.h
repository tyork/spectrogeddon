//
//  TimeSequence.h
//  Spectrogeddon
//
//  Created by Tom York on 18/11/2013.
//  
//

#import <Foundation/Foundation.h>

@interface TimeSequence : NSObject

@property (nonatomic) NSTimeInterval timeStamp;
@property (nonatomic) NSTimeInterval duration;

- (id)initWithValues:(NSArray*)values;

- (id)initWithNumberOfValues:(NSUInteger)count values:(float*)values;

- (id)initWithNumberOfValues:(NSUInteger)count values:(float*)values copy:(BOOL)copy;

- (NSArray*)values;

- (NSUInteger)numberOfValues;

- (float)valueAtIndex:(NSUInteger)valueIndex;

- (float*)rawValues;

- (void)appendTimeSequence:(TimeSequence*)timeSequence;

@end
