//
//  GameSuccessModalView.swift
//  ARWorld
//
//  Created by JinYingZhe on 2/19/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

protocol GameSuccessModalViewDelegate {
    func onClickSuccessNextUB ()
}

class GameSuccessModalView: UIView {
    @IBOutlet weak var rewardUL: UILabel!
    
    var delegate: GameSuccessModalViewDelegate?
    let radius: CGFloat = 15.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func onClickNextUB(_ sender: Any) {
        self.delegate?.onClickSuccessNextUB()
    }
    
}
