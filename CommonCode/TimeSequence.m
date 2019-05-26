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
        memcpy(newStorage + _count, timeSequence->_values, (timeSequence->_count)*sizeof(float));
        _values = newStorage;
        _count = _count + timeSequence->_count;
    }
}

@end
