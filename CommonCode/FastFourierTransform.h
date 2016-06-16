//
//  FastFourierTransform.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

@import Foundation;

@class TimeSequence;

@interface FastFourierTransform : NSObject

- (TimeSequence*)transformSequence:(TimeSequence*)sequence;

@end
