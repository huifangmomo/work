//
//  hqCell.swift
//  wallet_b
//
//  Created by xhf on 2018/7/18.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class hqCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lab_1: UILabel!
    @IBOutlet weak var lab_2: UILabel!
    @IBOutlet weak var priceLab: UILabel!
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var zdfLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
