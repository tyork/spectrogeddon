//
//  RenderSize.swift
//  Spectrogeddon
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import GLKit

struct RenderSize: Equatable {
    
    static let empty: RenderSize = .init(width: 0, height: 0)

    let width: GLint
    let height: GLint
}
