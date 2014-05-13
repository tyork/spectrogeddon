//
//  ScrollingRenderer.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 13/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScrollingRenderer <NSObject>

@property (nonatomic) float scrollingPosition;

@optional
@property (nonatomic) NSUInteger activeScrollingDirectionIndex;

- (NSArray*)namesForScrollingDirections;

@end
