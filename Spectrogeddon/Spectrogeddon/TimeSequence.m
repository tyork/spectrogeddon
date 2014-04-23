//
//  TimeSequence.m
//  Spectrogeddon
//
//  Created by Tom York on 18/11/2013.
//
//

#import "TimeSequence.h"

@implementation TimeSequence {
    float* _values;
    NSUInteger _count;
}

- (id)initWithValues:(NSArray*)values
{
    NSParameterAssert(values);
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _count = values.count;
    _values = (float*)calloc(values.count, sizeof(float));
    [values enumerateObjectsUsingBlock:^(NSNumber* oneNumber, NSUInteger idx, BOOL *stop) {
        _values[idx] = oneNumber.doubleValue;
    }];

    return self;
}

- (id)initWithNumberOfValues:(NSUInteger)count values:(float*)values
{
    NSParameterAssert(count);
    NSParameterAssert(values);
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _count = count;
    _values = calloc(count, sizeof(float));
    bcopy(values, _values, _count*sizeof(float));
    
    return self;
}

- (void)dealloc
{
    free(_values);
}

- (NSArray*)values
{
    NSMutableArray* values = [[NSMutableArray alloc] initWithCapacity:_count];
    for(NSUInteger valueIndex = 0; valueIndex < _count; valueIndex++)
    {
        [values addObject:@(_values[valueIndex])];
    }
    return values;
}

- (NSUInteger)numberOfValues
{
    return _count;
}

- (float)valueAtIndex:(NSUInteger)valueIndex
{
    NSParameterAssert(_count > valueIndex);
    return _values[valueIndex];
}

- (float*)rawValues
{
    return _values;
}

@end
