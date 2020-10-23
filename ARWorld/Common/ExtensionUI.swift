//
//  ExtensionUI.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/28/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

class ExtensionUI: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

enum UIShadowType: Int {
    case large
    case medium
    case small
}

extension UIView {
    func setPopItemViewStyle(cornerRadius radius: CGFloat, title: UIShadowType = .small) {
        switch title {
        case .small:
            do {
                self.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
                self.layer.shadowOpacity = 0.3
                self.layer.shadowRadius = 3.0
                self.layer.masksToBounds = false
            }
            break
        case .medium:
            break
        case .large:
            do {
                self.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
                self.layer.shadowRadius = 6.0
                self.layer.shadowOpacity = 0.3
                self.layer.masksToBounds = false
            }
            break
        }
        self.layer.cornerRadius = radius
    }
}
