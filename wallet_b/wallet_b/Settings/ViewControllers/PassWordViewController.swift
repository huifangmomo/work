//
//  PassWordViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/8/2.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class PassWordViewController: UIViewController {
    
    var showType:Int?
    var psdStatus:Int!
    var firstInput:String?
    var secInput:String?
    
    private var textField:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if showType==1 {
            psdStatus = 0
            let payAlert = PayAlert(frame: UIScreen.main.bounds)
            payAlert.titleLabel.text = "请输入新密码"
            payAlert.show_2(view: self.view)
            payAlert.completeBlock = ({(password:String) -> Void in
                print("输入的密码是:" + password)
                if self.psdStatus == 0{
                    self.firstInput = password
                    self.againPSD(payAlert: payAlert)
                }else if  self.psdStatus == 1{
                    self.secInput = password
                    if self.firstInput == self.secInput {
                        print("成功")
                        UserDefaults.standard.set(password, forKey: "passWord")
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.newPSD(payAlert: payAlert)
                    }
                }
            })
        }
    }
    
    func againPSD(payAlert : PayAlert){
        psdStatus = 1
        payAlert.titleLabel.text = "请再次输入新密码"
        payAlert.clearPSD()
    }
    
    func newPSD(payAlert : PayAlert){
        psdStatus = 0
        payAlert.titleLabel.text = "请输入新密码"
        payAlert.clearPSD()
        self.alert(text: "两次输入密码不一致")
    }
    
    func alert(text: String) {
        let alertController = UIAlertController(title: "提示",
                                                message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确认", style: .default, handler: {
            action in
            
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
