//
//  CopyViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/27.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import TrustKeystore

class CopyViewController: UIViewController {
    var account: Account!
    @IBOutlet weak var lab_1: UILabel!
    @IBOutlet weak var lab_2: UILabel!
    @IBOutlet weak var lab_3: UILabel!
    @IBOutlet weak var copyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(account)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        lab_1.text = LanguageHelper.getString(key: "无备份，不Ethereum")
        lab_2.text = LanguageHelper.getString(key: "只有你能掌控你的资产，为了防止它们因为应用被删而丢失，你需要备份 Keystore。")
        lab_3.text = LanguageHelper.getString(key: "你的钱包永远不会被保存到云存储，或者系统的标准设备备份里。")
        self.copyBtn.setTitle(LanguageHelper.getString(key: "备份钱包"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func copyCallback(_ sender: UIButton) {
        //跳转Identifier: "passNa"的viewcontroller
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "passNa") as! UINavigationController
        //传值
        let vc = controller.viewControllers.first as! PassWordTableViewController
        vc.account = account
        self.present(controller, animated: true, completion: nil)
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
