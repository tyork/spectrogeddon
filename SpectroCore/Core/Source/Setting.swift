//
//  Setting.swift
//  SpectroCore
//
//  Created by Tom York on 07/08/2019.
//

import Foundation

public struct Setting<T: Equatable> {
    
    public let defaultValue: T
    public let permittedValues: [T]
    public var value: T
    
    public init(_ initial: T? = nil, default: T, permitted: [T]) {
        
        precondition(permitted.contains(where: { $0 == `default` }))
        
        defaultValue = `default`
        permittedValues = permitted
        
        if let initialValue = initial, let _ = permitted.firstIndex(where: { $0 == initialValue }) {
            value = initialValue
        } else {
            value = defaultValue
        }
    }

    public mutating func nextValue() {
        
        if let index = permittedValues.firstIndex(where: { $0 == value }) {
            let nextIndex = (index + 1) % permittedValues.count
            value = permittedValues[nextIndex]
        }
    }
    
    @discardableResult
    public mutating func set(_ optionalValue: T?) -> T {
        
        if let value = optionalValue, permittedValues.contains(where: { $0 == value }) {
            self.value = value
        } else {
            self.value = defaultValue
        }
        return value
    }
    
}
