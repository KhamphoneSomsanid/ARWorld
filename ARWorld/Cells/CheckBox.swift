//
//  CheckBox.swift
//  ARWorld
//
//  Created by JinYingZhe on 4/2/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

class CheckBox: UIButton {

    // Images
    let checkedImage = UIImage(named: "ic_checked_back")! as UIImage
    let uncheckedImage = UIImage(named: "ic_uncheck_back")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, for: UIControl.State.normal)
            } else {
                self.setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }

}
