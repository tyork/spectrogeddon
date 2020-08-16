//
//  ColorMapProvider.swift
//  SpectroCore
//
//  Created by Tom York on 30/07/2019.
//

import Foundation

public typealias ColorMapName = String

public protocol ColorMapProvider {
    var names: [ColorMapName] { get }
    func nextColorMapNameAfter(name: ColorMapName) -> ColorMapName?
    func colorMap(name: ColorMapName) -> ColorMap?
}
