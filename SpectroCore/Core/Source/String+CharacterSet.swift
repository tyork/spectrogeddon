//
//  String+CharacterClasses.swift
//  SpectroCore
//
//  Created by Tom York on 14/07/2019.
//

import Foundation

extension String {
    
    func removing(charactersInSet set: CharacterSet) -> String {

        return components(separatedBy: set).joined(separator: "")
    }
}
