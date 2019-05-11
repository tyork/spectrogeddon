//
//  SampleSetMesh.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

@import GLKit;

@class TimeSequence;

NS_ASSUME_NONNULL_BEGIN

/**
 Renders a column, a single measurement set.
 */
@interface ColumnRenderer : NSObject

@property (nonatomic) BOOL useLogFrequencyScale;
@property (nonatomic) CGImageRef colorMapImage;
@property (nonatomic) GLKMatrix4 positioning;

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence offset:(float)offset width:(float)width;

- (void)render;

@end

NS_ASSUME_NONNULL_END
