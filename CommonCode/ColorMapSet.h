//
//  ColorMapSet.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import <Foundation/Foundation.h>

@interface ColorMapSet : NSObject

- (NSUInteger)imageCount;

- (UIImage*)imageAtIndex:(NSUInteger)imageIndex;

- (UIImage*)nextColorMap;

@end
