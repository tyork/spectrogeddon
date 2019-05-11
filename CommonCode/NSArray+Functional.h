//
//  NSArray+Functional.h
//  Spectrogeddon
//
//  Created by Tom York on 23/01/2015.
//  Copyright (c) 2015 Random. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Functional)

- (instancetype)spe_arrayByApplyingMap:(id(^)(id obj))map;

@end

NS_ASSUME_NONNULL_END
