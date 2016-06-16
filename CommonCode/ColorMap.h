//
//  ColorMap.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 08/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

@interface ColorMap : NSObject <NSCoding>

@property (nonatomic,copy,readonly) NSString* imageName;

- (instancetype)initWithImageName:(NSString*)imageName;

- (CGImageRef)imageRef;

@end
