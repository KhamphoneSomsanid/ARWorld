//
//  GetCrystalModalView.swift
//  ARWorld
//
//  Created by JinYingZhe on 1/28/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

protocol GetCrystalModalViewDelegate {
    func popGetCrystalModalViewDismissal()
    func popGetCrystalModalViewBtnClick()
}

class GetCrystalModalView: UIView {
    @IBOutlet weak var backUV: UIView!
    @IBOutlet weak var closeUB: UIButton!
    @IBOutlet weak var shopUB: UIButton!
    @IBOutlet weak var cancelUB: UIButton!
    
    var delegate: GetCrystalModalViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backUV.setPopItemViewStyle(cornerRadius: 30.0, title: .large)
        closeUB.setPopItemViewStyle(cornerRadius: closeUB.frame.width / 2.0, title: .small)
        shopUB.setPopItemViewStyle(cornerRadius: 20.0, title: .small)
        cancelUB.setPopItemViewStyle(cornerRadius: 20.0, title: .small)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func onClickCloseUB(_ sender: Any) {
        self.delegate?.popGetCrystalModalViewDismissal()
    }
    
    @IBAction func onClickCancelUB(_ sender: Any) {
        self.delegate?.popGetCrystalModalViewDismissal()
    }
    
    @IBAction func onClickShopUB(_ sender: Any) {
        self.delegate?.popGetCrystalModalViewBtnClick()
    }
    
}
