//
//  UIView+Autolayout.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 31/10/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit

extension UIView {
    
    @discardableResult
    func usingAutolayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult
    func pinToSuperviewEdges(edges: UIRectEdge = .all) -> Self {
        
        guard let s = superview else { return self }
        
        var pins: [NSLayoutConstraint] = []
        if edges.contains(.bottom) {
            pins.append(s.bottomAnchor.constraint(equalTo: bottomAnchor))
        }
        if edges.contains(.top) {
            pins.append(s.topAnchor.constraint(equalTo: topAnchor))
        }
        if edges.contains(.left) {
            pins.append(s.leadingAnchor.constraint(equalTo: leadingAnchor))
        }
        if edges.contains(.right) {
            pins.append(s.trailingAnchor.constraint(equalTo: trailingAnchor))
        }
        
        NSLayoutConstraint.activate(pins)
        
        return self
    }
}
