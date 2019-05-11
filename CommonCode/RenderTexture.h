//
//  RenderTexture.h
//  SpectrogeddonOSX
//
//  Created by Tom York on 12/05/2014.
//  Copyright (c) 2014 Spectrogeddon. All rights reserved.
//

@import Foundation;
#import "RendererTypes.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Allows you to draw into a texture that can then be rendered to a framebuffer elsewhere.
 */
@interface RenderTexture : NSObject

@property (nonatomic) RenderSize renderSize;

- (void)drawWithCommands:(void(^)(void))glCommands; // Draw into the texture.

- (void)renderTextureWithCommands:(void(^)(void))glCommands; // Binds the texture to TEXTURE2D before executing glCommands.

@end

NS_ASSUME_NONNULL_END
