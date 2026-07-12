//
//  GLRenderer.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 18/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation
import GLKit

class GLRenderer {
    
    var namesForScrollingDirections: [String] {
        return scrollingRenderer.namesForScrollingDirections
    }

    var renderSize: RenderSize {
        didSet {
            if renderSize != oldValue {
                resetTimeline()
                renderTexture.renderSize = scrollingRenderer.bestRenderSize(for: renderSize)
            }

        }
    }
    
    private var channel1Renderer: ColumnRenderer
    private var channel2Renderer: ColumnRenderer
    private var scrollingRenderer: ScrollingRenderer
    private var renderTexture: RenderTexture
    private var displaySettings: DisplaySettings?

    private var lastDuration: TimeInterval
    private var lastMeasurementTime: TimeInterval
    private var lastMeasurementPosition: Float
    
    private var scrollingPositionNow: Float {
        guard lastMeasurementTime > 0 else {
            return 0
        }

        return normalizedFraction(
            TimeInterval(lastMeasurementPosition) + TimeInterval(widthFromTimeInterval(CACurrentMediaTime() - lastMeasurementTime))
        )
    }

    
    init() {
        self.renderSize = .init(width: 0, height: 0)
        self.scrollingRenderer = LinearScrollingRenderer()
        self.renderTexture = RenderTexture()
        self.channel1Renderer = ColumnRenderer()
        self.channel2Renderer = ColumnRenderer()
        lastDuration = 0
        lastMeasurementTime = 0
        lastMeasurementPosition = 0
    }

    func addMeasurements(_ channels: [TimeSequence]) {
        
        guard !channels.isEmpty else {
            return
        }
        
        // TODO: model this better
        let showStereo = channels.count > 1
        let currentMeasurementTime = CACurrentMediaTime()
        let measuredDuration = max(channels[0].duration, 0)
        let elapsedMeasurementTime = lastMeasurementTime > 0 ? currentMeasurementTime - lastMeasurementTime : measuredDuration
        let previousMeasurementPosition = lastMeasurementPosition
        lastDuration = measuredDuration
        let measuredWidth = widthFromTimeInterval(elapsedMeasurementTime)
        let renderSegments = splitRenderSegment(offset: previousMeasurementPosition, width: measuredWidth)

        if showStereo {
            channel1Renderer.positioning = positionForChannelAtIndex(channelIndex: 0, totalChannels: 2)
            channel2Renderer.positioning = positionForChannelAtIndex(channelIndex: 1, totalChannels: 2)
        } else {
            channel1Renderer.positioning = positionForChannelAtIndex(channelIndex: 0, totalChannels: 1)
        }

        renderTexture.draw { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.renderChannel(renderer: strongSelf.channel1Renderer, withSequence: channels[0], segments: renderSegments)
            if showStereo {
                strongSelf.renderChannel(renderer: strongSelf.channel2Renderer, withSequence: channels[1], segments: renderSegments)
            }
            strongSelf.lastMeasurementPosition = strongSelf.normalizedFraction(TimeInterval(previousMeasurementPosition + measuredWidth))
            strongSelf.lastMeasurementTime = currentMeasurementTime
        }
    }
    
    func render() {
        
        guard renderSize != .empty, displaySettings != nil else {
            return
        }
        
        scrollingRenderer.scrollingPosition = scrollingPositionNow
        glViewport(0, 0, renderSize.width, renderSize.height)
        glClearColor(0, 0, 1, 1)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        renderTexture.renderTexture {
            self.scrollingRenderer.render()
        }
    }
    
    func use(_ displaySettings: DisplaySettings) {
        
        self.displaySettings = displaySettings
        channel1Renderer.colorMapImage = displaySettings.colorMap!.image
        channel2Renderer.colorMapImage = displaySettings.colorMap!.image
        channel1Renderer.useLogFrequencyScale = displaySettings.useLogFrequencyScale
        channel2Renderer.useLogFrequencyScale = displaySettings.useLogFrequencyScale
        scrollingRenderer.activeScrollingDirectionIndex = displaySettings.scrollingDirectionIndex
        let bestRenderSize = scrollingRenderer.bestRenderSize(for: renderSize)
        if renderTexture.renderSize != bestRenderSize {
            resetTimeline()
        }
        renderTexture.renderSize = bestRenderSize
    }
    
    private func positionForChannelAtIndex(channelIndex: UInt, totalChannels: UInt) -> GLKMatrix4 {
        
        guard totalChannels > 0 else {
            return GLKMatrix4Identity
        }
        
        let channelHeight: Float = 2 / Float(totalChannels)
        let flipChannel: Bool = (channelIndex & 1) == 1 // Flip odd numbered channels.
        let center: Float = 1 - channelHeight * Float(channelIndex + 1 - (flipChannel ? 1 : 0))
        let positioning: GLKMatrix4 = GLKMatrix4MakeTranslation(0, center, 0)
        return GLKMatrix4Scale(positioning, 1, channelHeight*(flipChannel ? -1 : 1), 1)
    }
    
    private func renderChannel(renderer: ColumnRenderer, withSequence timeSequence: TimeSequence, segments: [(offset: Float, width: Float)]) {

        for segment in segments {
            renderer.updateVertices(timeSequence: timeSequence, offset: (2 * segment.offset - 1), width: 2 * segment.width)
            renderer.render()
        }
    }
    
    private func widthFromTimeInterval(_ timeInterval: TimeInterval) -> Float {

        guard let textureCycleDuration = textureCycleDuration else {
            return 0
        }
        return Float(timeInterval / textureCycleDuration)
    }

    private var textureCycleDuration: TimeInterval? {

        guard
            let displaySettings = displaySettings,
            displaySettings.scrollingSpeed > 0,
            lastDuration > 0,
            renderTexture.renderSize.width > 0 else {
            return nil
        }

        return lastDuration * TimeInterval(renderTexture.renderSize.width) / TimeInterval(displaySettings.scrollingSpeed)
    }

    private func splitRenderSegment(offset: Float, width: Float) -> [(offset: Float, width: Float)] {

        guard width > 0 else {
            return []
        }

        if width >= 1 {
            return [(offset: 0, width: 1)]
        }

        let firstSegmentWidth = min(width, 1 - offset)
        var segments = [(offset: offset, width: firstSegmentWidth)]
        let remainingWidth = width - firstSegmentWidth
        if remainingWidth > 0 {
            segments.append((offset: 0, width: remainingWidth))
        }
        return segments
    }

    private func resetTimeline() {

        lastMeasurementTime = 0
        lastMeasurementPosition = 0
    }

    private func normalizedFraction(_ value: TimeInterval) -> Float {

        guard value.isFinite else {
            return 0
        }
        return Float(value - floor(value))
    }
}
