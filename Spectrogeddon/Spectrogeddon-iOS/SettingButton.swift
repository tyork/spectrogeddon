//
//  SettingButton.swift
//  Spectrogeddon-iOS
//
//  Created by Tom York on 31/10/2019.
//  Copyright © 2019 Random. All rights reserved.
//

import UIKit

class SettingButton: UIButton {
    
    typealias TouchHandler = () -> Void
    
    var touchHandler: TouchHandler?
    
    convenience init(title: String, handler: @escaping TouchHandler) {
        
        self.init(type: .custom)
        touchHandler = handler
        titleLabel?.textAlignment = .center
        setTitle(title, for: .normal)
        setTitleColor(UIColor(white: 0.97, alpha: 1), for: .highlighted)
        setTitleColor(.lightGray, for: .highlighted)
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
    }
    
    @objc
    private func didTouchUpInside() {
        touchHandler?()
    }
}
