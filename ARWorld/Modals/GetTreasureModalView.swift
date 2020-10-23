//
//  GetTreasureModalView.swift
//  ARWorld
//
//  Created by JinYingZhe on 2/19/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

protocol GetTreasureModalViewDelegate {
    func popGetTreasureOpenClick()
    func popGetTreasurePutClick()
    func popGetTreasureViewDismissal()
}

class GetTreasureModalView: UIView {
    @IBOutlet weak var backUV: UIView!
    @IBOutlet weak var closeUB: UIButton!
    @IBOutlet weak var openUB: UIButton!
    @IBOutlet weak var putUB: UIButton!
    
    var delegate: GetTreasureModalViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backUV.setPopItemViewStyle(cornerRadius: 30.0, title: .large)
        closeUB.setPopItemViewStyle(cornerRadius: closeUB.frame.width / 2.0, title: .small)
        openUB.setPopItemViewStyle(cornerRadius: 20.0, title: .small)
        putUB.setPopItemViewStyle(cornerRadius: 20.0, title: .small)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func onClickPutUB(_ sender: Any) {
        self.delegate?.popGetTreasurePutClick()
    }
    
    @IBAction func onClickOpenUB(_ sender: Any) {
        self.delegate?.popGetTreasureOpenClick()
    }
    
    @IBAction func onClickCloseUB(_ sender: Any) {
        self.delegate?.popGetTreasureViewDismissal()
    }

}
