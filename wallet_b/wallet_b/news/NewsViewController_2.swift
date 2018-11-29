//
//  NewsViewController_2.swift
//  wallet_b
//
//  Created by xhf on 2018/7/18.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class NewsViewController_2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.darkGray
        
        let textLabel = UILabel(frame: CGRect(x: 0, y: 100, width: self.view.frame.width,
                                              height: 30))
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 33)
        textLabel.textColor = .white
        textLabel.text = "资讯"
        view.addSubview(textLabel)
    }
    
    func upDataTableView() {
        print("资讯upDataTableView")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
