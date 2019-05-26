//
//  LinearScrollingRenderer.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 24/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import GLKit

/// Displays a texture on a linear repeating mesh.
class LinearScrollingRenderer: ScrollingRenderer {
    
    var scrollingPosition: Float
    
    var activeScrollingDirectionIndex: UInt
    
    var namesForScrollingDirections: [String] {
        
        return [
            NSLocalizedString("Horizontal", comment: ""),
            NSLocalizedString("Vertical", comment: "")
        ]
    }
    
    private lazy var mesh: ShadedMesh = {
        
        var bufferMesh: [TexturedVertexAttribs] = [
            .init(x: -3, y: 1, s: 0, t: 1),
            .init(x: -3, y: -1, s: 0, t: 0),
            .init(x: -1, y: 1, s: 1, t: 1),
            .init(x: -1, y: -1, s: 1, t: 0),
            .init(x: -1, y: 1, s: 0, t: 1),
            .init(x: -1, y: -1, s: 0, t: 0),
            .init(x: 1, y: 1, s: 1, t: 1),
            .init(x: 1, y: -1, s: 1, t: 0)
        ]

        let mesh = ShadedMesh(numberOfVertices: bufferMesh.count)
        mesh.updateVertices { storage in
            
            for index in (0..<bufferMesh.count) {
                storage[index] = bufferMesh[index]
            }
        }
        return mesh
    }()
    
    init() {
        self.scrollingPosition = 0
        self.activeScrollingDirectionIndex = 0
    }

    func bestRenderSize(for size: RenderSize) -> RenderSize {

        if activeScrollingDirectionIndex == 0 {
            return size
        } else {
            return RenderSize(width: size.height, height: size.width)
        }
    }
    
    func render() {
        mesh.transform = transform()
        mesh.render()
    }
    
    private func transform() -> GLKMatrix4 {
        
        let translationOffset = 2 * (1 - scrollingPosition)
        let translation = GLKMatrix4MakeTranslation(translationOffset, 0, 0)
        if activeScrollingDirectionIndex == 0 {
            return translation
        } else {
            let rotation = GLKMatrix4MakeRotation(-Float.pi/2, 0, 0, 1)
            return GLKMatrix4Multiply(rotation, translation)
        }
    }
}
