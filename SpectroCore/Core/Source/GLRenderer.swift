//
//  GLRenderer.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 18/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation
import GLKit

public class GLRenderer {
    
    public var namesForScrollingDirections: [String] {
        return scrollingRenderer.namesForScrollingDirections
    }

    public var renderSize: RenderSize {
        
        didSet {
            if renderSize != oldValue {
                frameOriginTime = 0
                renderTexture.renderSize = scrollingRenderer.bestRenderSize(for: renderSize)
            }
        }
    }
    
    private var channel1Renderer: ColumnRenderer
    private var channel2Renderer: ColumnRenderer
    private var scrollingRenderer: ScrollingRenderer
    private var renderTexture: RenderTexture
    private var displaySettings: ApplicationSettings?

    private var lastDuration: TimeInterval
    private var frameOriginTime: TimeInterval
    private var lastRenderedSampleTime: TimeInterval
    private let colorMapProvider: ColorMapProvider
    
    private var scrollingPositionNow: Float {
        let nowTime = CACurrentMediaTime()
        if frameOriginTime <= 0 {
            frameOriginTime = nowTime
        }
        
        var position = widthFromTimeInterval(nowTime - frameOriginTime)
        if position > 1 {
            frameOriginTime = nowTime
            position = 0
        }
        return position
    }

    public init(colorMapProvider: ColorMapProvider) {
        
        self.colorMapProvider = colorMapProvider
        self.renderSize = .init(width: 0, height: 0)
        self.scrollingRenderer = LinearScrollingRenderer()
        self.renderTexture = RenderTexture()
        self.channel1Renderer = ColumnRenderer()
        self.channel2Renderer = ColumnRenderer()
        frameOriginTime = 0
        lastDuration = 0
        lastRenderedSampleTime = 0
    }

    public func addMeasurements(_ channels: [TimeSequence]) {
        
        guard !channels.isEmpty else {
            return
        }
        
        // TODO: model this better
        let showStereo = channels.count > 1
        if showStereo {
            channel1Renderer.positioning = positionForChannelAtIndex(channelIndex: 0, totalChannels: 2)
            channel2Renderer.positioning = positionForChannelAtIndex(channelIndex: 1, totalChannels: 2)
            updateChannelRenderer(renderer: channel1Renderer, withSequence: channels[0])
            updateChannelRenderer(renderer: channel2Renderer, withSequence: channels[1])
        } else {
            channel1Renderer.positioning = positionForChannelAtIndex(channelIndex: 0, totalChannels: 1)
            updateChannelRenderer(renderer: channel1Renderer, withSequence: channels[0])
        }

        renderTexture.draw { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            strongSelf.channel1Renderer.render()
            if showStereo {
                strongSelf.channel2Renderer.render()
            }
            strongSelf.lastRenderedSampleTime = channels[0].timeStamp
        }
    }
    
    public func render() {
        
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
    
    public func use(_ settings: ApplicationSettings) {
        
        guard
            let colorMapName = settings.colorMapName.value,
            let colorMap = colorMapProvider.colorMap(name: colorMapName) else {
            return
        }
        
        let image = colorMap.image
        
        self.displaySettings = settings
        channel1Renderer.colorMapImage = image
        channel2Renderer.colorMapImage = image
        channel1Renderer.useLogFrequencyScale = settings.useLogFrequencyScale.value
        channel2Renderer.useLogFrequencyScale = settings.useLogFrequencyScale.value
        scrollingRenderer.activeScrollingDirectionIndex = settings.scrollingDirectionIndex.value
        renderTexture.renderSize = scrollingRenderer.bestRenderSize(for: renderSize)
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
    
    private func updateChannelRenderer(renderer: ColumnRenderer, withSequence timeSequence: TimeSequence) {
    
        var baseOffset = widthFromTimeInterval(timeSequence.timeStamp - frameOriginTime)
        if baseOffset > 1 {
            baseOffset = 0
        }
        lastDuration = timeSequence.duration
        let width = widthFromTimeInterval(timeSequence.duration + timeSequence.timeStamp - lastRenderedSampleTime)
        renderer.updateVertices(timeSequence: timeSequence, offset: (2 * baseOffset - 1), width: width)
    }
    
    private func widthFromTimeInterval(_ timeInterval: TimeInterval) -> Float {
        
        let screenFractionPerSecond = Float(displaySettings?.scrollingSpeed.value ?? 0)/(Float(lastDuration) * Float(renderTexture.renderSize.width))
        return screenFractionPerSecond * Float(timeInterval)
    }
}
