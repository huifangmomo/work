//
//  AddressBookCell.swift
//  wallet_b
//
//  Created by xhf on 2018/8/1.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class AddressBookCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var info: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
