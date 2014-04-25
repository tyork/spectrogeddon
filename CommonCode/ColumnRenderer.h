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

@property (nonatomic,assign) CGImageRef colorMapImage;

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence offset:(float)offset width:(float)width;

- (void)render;

@end
