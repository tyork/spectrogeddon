//
//  RadialScrollingRenderer.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 24/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

private let numberOfSpokes = 48
private let numberOfVerticesPerSpoke = 4
private let numberOfBufferVertices = (numberOfSpokes + 1) * numberOfVerticesPerSpoke

class RadialScrollingRenderer: NSObject, ScrollingRenderer {

    var scrollingPosition: Float
    
    var activeScrollingDirectionIndex: UInt {
        didSet {
            setupVertices()
        }
    }
    
    private var mesh: ShadedMesh
    
    override init() {
        self.scrollingPosition = 0
        self.activeScrollingDirectionIndex = 0
        self.mesh = ShadedMesh(numberOfVertices: UInt(numberOfBufferVertices))
        super.init()
        setupVertices()
    }
    
    func bestRenderSize(from size: RenderSize) -> RenderSize {
        return size
    }
    
    func namesForScrollingDirections() -> [String] {
        
        return [
            NSLocalizedString("Inwards", comment: ""),
            NSLocalizedString("Outwards", comment: "")
        ]
    }
    
    func render() {

        let offset = activeScrollingDirectionIndex == 0 ? scrollingPosition : (1 - scrollingPosition)
        let contraOffset = 1 - offset
        let edgeV = scrollingPosition
        let stripOffset = numberOfBufferVertices/2

        mesh.updateVertices { v in

            for spokeIndex in (0...numberOfSpokes) {
                
                let innerIndex = spokeIndex * 2 // 2 points per strip
                let outerIndex = innerIndex + stripOffset + 1
                v[innerIndex].s = edgeV
                v[outerIndex].s = edgeV
                let xOffset = offset * v[innerIndex].x + contraOffset * v[outerIndex].x
                let yOffset = offset * v[innerIndex].y + contraOffset * v[outerIndex].y
                v[outerIndex-1].x = xOffset
                v[outerIndex-1].y = yOffset
                v[innerIndex+1].x = xOffset
                v[innerIndex+1].y = yOffset
            }
        }
        
        mesh.render()
    }

    private func setupVertices() {

        let stripOffset = numberOfBufferVertices/2
        let innerRadius: Float = 0
        let outerRadius: Float = sqrt(2)
        let edgeV: Float = activeScrollingDirectionIndex == 0 ? 0 : 1

        mesh.updateVertices { v in
            
            for spokeIndex in (0...numberOfSpokes) {
                let fractionOfEdges = Float(spokeIndex)/Float(numberOfSpokes)
                let angle = 2 * Float.pi * fractionOfEdges
                let position = GLKVector2Make(sin(angle), cos(angle))
                
                let innerVertexIndex = spokeIndex * 2 // 2 points per strip
                let outerVertexIndex = innerVertexIndex + stripOffset + 1
                
                let innerX = position.x*innerRadius
                let innerY = position.y*innerRadius

                let outerX = position.x*outerRadius
                let outerY = position.y*outerRadius

                v[innerVertexIndex] = TexturedVertexAttribs(x: innerX, y: innerY, s: edgeV, t: fractionOfEdges)
                v[innerVertexIndex+1] = TexturedVertexAttribs(x: outerX, y: outerY, s: 1 - edgeV, t: fractionOfEdges)
                v[outerVertexIndex-1] = TexturedVertexAttribs(x: outerX, y: outerY, s: edgeV, t: fractionOfEdges)
                v[outerVertexIndex] = TexturedVertexAttribs(x: outerX, y: outerY, s: edgeV, t: fractionOfEdges)
            }
        }
    }
}
