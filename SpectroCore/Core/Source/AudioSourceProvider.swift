//
//  AudioSourceProvider.swift
//  SpectroCore
//
//  Created by Tom York on 30/07/2019.
//

import Foundation

public typealias AudioSourceName = String
public typealias AudioSourceID = String

public protocol AudioSourceProvider {
    var availableSources: [AudioSourceName: AudioSourceID] { get }
}
