//
//  GoodUIViewCell.swift
//  AR_Purchase
//
//  Created by JinYingZhe on 1/14/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

protocol GoodUIViewCellDelegate {
    func onClickPurchaseDelegate(withGood good: GoodModel)
}

class GoodUIViewCell: UIView {
    
    @IBOutlet weak var goodNameUL: UILabel!
    @IBOutlet weak var crystalCntUL: UILabel!
    @IBOutlet weak var crystalUIV: UIImageView!
    @IBOutlet weak var costUL: UILabel!
    @IBOutlet weak var lightUIV: UIImageView!
    @IBOutlet weak var gettingIcoImg: UIImageView!
    
    var good = GoodModel()    
    var delegate: GoodUIViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //  Initialation code
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func onClickPuchaseUB(_ sender: Any) {
        delegate?.onClickPurchaseDelegate(withGood: good)
    }
    
}
