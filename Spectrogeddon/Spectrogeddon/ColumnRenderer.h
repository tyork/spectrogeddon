//
//  SampleSetMesh.h
//  Spectrogeddon
//
//  Created by Tom York on 22/04/2014.
//  
//

#import <GLKit/GLKit.h>

@class TimeSequence;

@interface ColumnRenderer : NSObject

@property (nonatomic) float scrollingSpeed;
@property (nonatomic,strong) UIImage* colorMapImage;

- (void)updateVerticesForTimeSequence:(TimeSequence*)timeSequence;

- (void)render;

@end
