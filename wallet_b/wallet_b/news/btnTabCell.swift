//
//  btnTabCell.swift
//  wallet_b
//
//  Created by xhf on 2018/7/18.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

// 1.定义一个闭包类型
//格式: typealias 闭包名称 = (参数名称: 参数类型) -> 返回值类型
typealias swiftBlock = (_ str: String,_ str1:String) -> Void

class btnTabCell: UITableViewCell {

    @IBOutlet weak var btn1: topDownBtn!
    @IBOutlet weak var btn2: topDownBtn!
    @IBOutlet weak var btn3: topDownBtn!
    @IBOutlet weak var btn4: topDownBtn!
    
    var btnList = [UIView]()
    var btnTitleList = [UILabel]()
    var upImgList = [UIImageView]()
    var downImgList = [UIImageView]()
    var btnIndex = 0
    var btnType = 0 //0 为初始状态   1为从低到高   2为从高到低
    
    //2. 声明一个变量
    var callBack: swiftBlock?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnList = [self.btn1, self.btn2, self.btn3, self.btn4]
        for item in btnList {
            let stackView_1 = item.viewWithTag(10)
            btnTitleList.append(stackView_1?.viewWithTag(11) as! UILabel)
            let stackView_2 = stackView_1?.viewWithTag(12)
            upImgList.append(stackView_2?.viewWithTag(13) as! UIImageView)
            downImgList.append(stackView_2?.viewWithTag(14) as! UIImageView)
        }
    }
    
    //3. 定义一个方法,方法的参数为和swiftBlock类型一致的闭包,并赋值给callBack
    func callBackBlock(_ block: @escaping swiftBlock) {
        callBack = block
    }
    
    @IBAction func btnCallback(_ sender: UIButton) {
        btnIndex = sender.tag
        let btnIndexStr1 = UserDefaults.standard.integer(forKey: "btnIndex")
        if btnIndexStr1 != btnIndex{
            btnType = 0
        }
        for item in upImgList {
            item.image = R.image.btn_triangle_1()
        }
        for item in downImgList {
            item.image = R.image.btn_triangle_3()
        }
        for item in btnTitleList {
            item.textColor = UIColor(hex: "999999")
        }
        btnTitleList[btnIndex].textColor = UIColor(hex: "6693ff")
        if btnType==1 {
            btnType = 2
            downImgList[btnIndex].image = R.image.btn_triangle_4()
        }else{
            btnType = 1
            upImgList[btnIndex].image = R.image.btn_triangle_2()
        }
        UserDefaults.standard.set(btnIndex, forKey: "btnIndex")

        var str:String!
        var str1:String!
        if btnIndex == 0 {
            str = "market_cap"
        }else if btnIndex == 1{
            str = "volume_24h"
        }else if btnIndex == 2{
            str = "price"
        }else if btnIndex == 3{
            str = "change_1h"
        }
        if btnType == 1 {
            str1 = " DESC"
        }
        else if btnType == 2{
            str1 = ""
        }
        
        //4. 调用闭包,设置你想传递的参数,调用前先判定一下,是否已实现
        if callBack != nil {
            callBack!(str,str1)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
