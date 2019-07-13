//
//  DisplaySettings.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

public struct DisplaySettings: Codable {
    public var sharpness: UInt = 1
    public var scrollingSpeed: Int = 1
    public var scrollingDirectionIndex: UInt = 0
    public var useLogFrequencyScale: Bool = false
    public var colorMap: ColorMap? = nil
    public var preferredAudioSourceId: String? = nil
}
