//
//  HistoryTableViewCell.swift
//  ARWorld
//
//  Created by JinYingZhe on 4/2/19.
//  Copyright © 2019 JinYingZhe. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var noUL: UILabel!
    @IBOutlet weak var typeUL: UILabel!
    @IBOutlet weak var priceUL: UILabel!
    @IBOutlet weak var datetimeUL: UILabel!
    
    var data: HistoryInfo = HistoryInfo()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func reload() {
        noUL.text = "\(data.id)"
        if data.isOpened {
            typeUL.text = "打 开"
            typeUL.textColor = .blue
        } else {
            typeUL.text = "未开封"
            typeUL.textColor = .red
        }
        switch data.type {
        case 1:
            priceUL.text = "金 : " + data.gift
            break
        case 2:
            priceUL.text = "钻石 : " + data.gift
            break
        default:
            priceUL.text = "钱  : \(CGFloat(Int(data.gift)!) / 100.0) 元"
            typeUL.text = "采购"
            typeUL.textColor = .green
            break
        }
        datetimeUL.text = data.datetime        
    }

}
