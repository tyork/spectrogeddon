//
//  FastFourierTransform.h
//  Spectrogeddon
//
//  Created by Tom York on 14/04/2014.
//  
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class TimeSequence;

@interface FastFourierTransform : NSObject

- (TimeSequence*)transformSequence:(TimeSequence*)sequence;

@end

NS_ASSUME_NONNULL_END
