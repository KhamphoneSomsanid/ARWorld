//
//  GetAddressModalView.swift
//  ARWorld
//
//  Created by JinYingZhe on 2/19/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

protocol GetAddressModalViewDelegate {
    func popGetAddressConfirmClick()
    func popGetAddressViewDismissal()
}

class GetAddressModalView: UIView {
    @IBOutlet weak var backUV: UIView!
    @IBOutlet weak var closeUB: UIButton!
    @IBOutlet weak var confirmUB: UIButton!
    @IBOutlet weak var addressUF: UITextField!
    
    var delegate: GetAddressModalViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backUV.setPopItemViewStyle(cornerRadius: 30.0, title: .large)
        closeUB.setPopItemViewStyle(cornerRadius: closeUB.frame.width / 2.0, title: .small)
        confirmUB.setPopItemViewStyle(cornerRadius: 20.0, title: .small)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func onClickConfirmUB(_ sender: Any) {
        self.delegate?.popGetAddressConfirmClick()
    }
    
    @IBAction func onClickCloseUB(_ sender: Any) {
        self.delegate?.popGetAddressViewDismissal()
    }

}
