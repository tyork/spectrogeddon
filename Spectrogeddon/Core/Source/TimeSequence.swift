//
//  TimeSequence.swift
//  SpectrogeddonOSX
//
//  Created by Tom York on 26/05/2019.
//  Copyright © 2019 Spectrogeddon. All rights reserved.
//

import Foundation

public struct TimeSequence {

    public let timeStamp: TimeInterval
    public let duration: TimeInterval
    public var values: [Float]
    
    public init(timeStamp: TimeInterval, duration: TimeInterval, values: [Float]) {
        self.timeStamp = timeStamp
        self.duration = duration
        self.values = values
    }
}
