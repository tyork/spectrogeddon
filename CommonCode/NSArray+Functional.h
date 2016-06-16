//
//  NSArray+Functional.h
//  Spectrogeddon
//
//  Created by Tom York on 23/01/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

@import Foundation;

@interface NSArray (Functional)

- (NSArray*)spe_arrayByApplyingMap:(id(^)(id obj))map;

@end
