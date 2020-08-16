//
//  ScrollingRenderer.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 24/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

protocol ScrollingRenderer {

    var scrollingPosition: Float { get set }

    var activeScrollingDirectionIndex: UInt { get set }

    var namesForScrollingDirections: [String] { get }
    
    func bestRenderSize(for size: RenderSize) -> RenderSize

    func render()
}
