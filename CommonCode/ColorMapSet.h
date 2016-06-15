//
//  ColorMapSet.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

@import Foundation;

@class ColorMap;

@interface ColorMapSet : NSObject <NSCoding>

- (ColorMap*)currentColorMap;
- (ColorMap*)nextColorMap;

@end
