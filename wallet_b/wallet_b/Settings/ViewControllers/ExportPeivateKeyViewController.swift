//
//  ExportPeivateKeyViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/8/1.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class ExportPeivateKeyViewController: UIViewController {
    @IBOutlet weak var title_1: UILabel!
    @IBOutlet weak var title_2: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    
    var str: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addressLabel.text = str
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = LanguageHelper.getString(key: "导出私钥")
        self.title_1.text = LanguageHelper.getString(key: "导出风险自负")
        self.title_2.text = LanguageHelper.getString(key: "任何拥有私钥的人都可以访问你的钱包")
        self.copyBtn.setTitle(LanguageHelper.getString(key: "复制"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func copyCallback(_ sender: UIButton) {
        UIPasteboard.general.string = self.addressLabel.text
        alert(text: LanguageHelper.getString(key: "已经复制私钥到剪贴板"))
    }
    
    func alert(text: String) {
        let alertController = UIAlertController(title: LanguageHelper.getString(key: "提示"),
                                                message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LanguageHelper.getString(key: "确认"), style: .default, handler: {
            action in
            
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
