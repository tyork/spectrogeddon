//
//  RenderSize.swift
//  Spectrogeddon
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import GLKit

public struct RenderSize: Equatable {
    
    public static let empty: RenderSize = .init(width: 0, height: 0)

    public let width: GLint
    public let height: GLint
    
    public init(width: GLint, height: GLint) {
        self.width = width
        self.height = height
    }
}
