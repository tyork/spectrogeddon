//
//  SampleSetMesh.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import <GLKit/GLKit.h>

@class TimeSequence;

/**
 Renders a column, a single measurement set.
 */
@interface ColumnRenderer : NSObject

@property (nonatomic) CGImageRef colorMapImage;
@property (nonatomic) GLKMatrix4 positioning;

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence offset:(float)offset width:(float)width;

- (void)render;

@end
