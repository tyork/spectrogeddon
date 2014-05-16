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
    BOOL _didCopy;
}

- (id)initWithValues:(NSArray*)values
{
    NSParameterAssert(values);
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _didCopy = YES;
    _count = values.count;
    _values = (float*)calloc(values.count, sizeof(float));
    [values enumerateObjectsUsingBlock:^(NSNumber* oneNumber, NSUInteger idx, BOOL *stop) {
        _values[idx] = oneNumber.doubleValue;
    }];

    return self;
}

- (id)initWithNumberOfValues:(NSUInteger)count values:(float*)values
{
    return [self initWithNumberOfValues:count values:values copy:YES];
}

- (id)initWithNumberOfValues:(NSUInteger)count values:(float*)values copy:(BOOL)copy
{
    NSParameterAssert(count);
    NSParameterAssert(values);
    if(!(self = [super init]))
    {
        return nil;
    }
    
    _count = count;
    if(copy)
    {
        _didCopy = YES;
        _values = calloc(count, sizeof(float));
        memcpy(_values, values, _count*sizeof(float));
    }
    else
    {
        _values = values;
    }
    
    return self;
}

- (void)dealloc
{
    if(_didCopy)
    {
        free(_values);
    }
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

- (void)appendTimeSequence:(TimeSequence*)timeSequence
{
    float* newStorage = (float*)realloc(_values, (_count + timeSequence->_count)*sizeof(float));
    if(newStorage)
    {
        bcopy(timeSequence->_values, newStorage + _count, (timeSequence->_count)*sizeof(float));
        _values = newStorage;
        _count = _count + timeSequence->_count;
    }
}

@end
