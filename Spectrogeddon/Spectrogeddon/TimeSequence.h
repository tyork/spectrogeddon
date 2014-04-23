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

- (NSArray*)values;

- (NSUInteger)numberOfValues;

- (float)valueAtIndex:(NSUInteger)valueIndex;

- (float*)rawValues;

@end
