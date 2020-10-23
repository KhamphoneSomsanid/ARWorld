//
//  GameFailedModalView.swift
//  ARWorld
//
//  Created by JinYingZhe on 2/19/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

protocol GameFailedModalViewDelegate {
    func onClickFailedQuitUB ()
    func onClickFailedRetryUB ()
}

class GameFailedModalView: UIView {
    @IBOutlet weak var descriptionUL: UILabel!
    @IBOutlet weak var backUV: UIView!
    
    var delegate: GameFailedModalViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        backUV.setPopItemViewStyle(cornerRadius: 15.0, title: .large)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func onClickQuitUB(_ sender: Any) {
        self.delegate?.onClickFailedQuitUB()
    }
    
    @IBAction func onClickRetryUB(_ sender: Any) {
        self.delegate?.onClickFailedRetryUB()
    }
    

}
