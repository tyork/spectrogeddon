//
//  NSArray+Functional.m
//  Spectrogeddon
//
//  Created by Tom York on 23/01/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (instancetype)spe_arrayByApplyingMap:(id(^)(id obj))map
{
    if(map == nil) {
        return self;
    }
    NSMutableArray* mapped = [[NSMutableArray alloc] initWithCapacity:self.count];
    for(id oneItem in self) {
        id mappedObject = map(oneItem);
        if(mappedObject != nil) {
            [mapped addObject:mappedObject];
        }
    }
    return [mapped copy];
}

@end
