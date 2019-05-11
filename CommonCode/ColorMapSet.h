//
//  ColorMapSet.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

@import Foundation;

@class ColorMap;

NS_ASSUME_NONNULL_BEGIN

@interface ColorMapSet : NSObject <NSCoding>

- (ColorMap*)currentColorMap;
- (ColorMap*)nextColorMap;

@end

NS_ASSUME_NONNULL_END
