//
//  walletManageCell.swift
//  wallet_b
//
//  Created by xhf on 2018/7/30.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class walletManageCell: UITableViewCell {

    @IBOutlet weak var markImage: UIImageView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var nameLab: UILabel!
    @IBOutlet weak var addressLab: UILabel!
    @IBOutlet weak var balanceLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
