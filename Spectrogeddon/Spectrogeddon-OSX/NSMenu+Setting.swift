//
//  NSMenu+Setting.swift
//  Spectrogeddon-OSX
//
//  Created by Tom York on 06/10/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import AppKit
import SpectroCoreOSX

extension NSMenu {
    
    func replaceItems<T>(fromSetting setting: Setting<T>, selector: Selector) {
        
        removeAllItems()
        for value in setting.permittedValues {
            let title = String(describing: value)
            let charCode: String = title.count == 1 ? title.prefix(1).lowercased() : ""
            let item = NSMenuItem(title: title, action: selector, keyEquivalent: charCode)
            item.state = (value == setting.value) ? .on : .off
            item.representedObject = value
            addItem(item)
        }
    }

}
