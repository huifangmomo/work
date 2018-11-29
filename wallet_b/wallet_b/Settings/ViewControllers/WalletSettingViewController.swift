//
//  WalletSettingViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/31.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class WalletSettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var managerMainViewController:ManagerMainViewController!
    var wallet:Wallet!
    
    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "passWordView") as! PassWordViewController

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var touchView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let titleTab = ["钱包设置","备份 Keystore","导出私钥","复制地址","删除钱包"]
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell_"+String(indexPath.row), for: indexPath)
        if indexPath.row == 0 {
            let btn = cell.viewWithTag(2) as! UIButton
            btn.addTarget(self,action:#selector(backCallback),for:.touchUpInside)
            cell.selectionStyle = .none
        }
        let label = cell.viewWithTag(1) as! UILabel
        label.text = LanguageHelper.getString(key: titleTab[indexPath.row])
        if indexPath.row == 0{
            label.textColor = UIColor(hex: "6693ff")
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
        }else if indexPath.row == 4 {
            if managerMainViewController.selectIndexPath?.row == 0 {
                label.textColor = UIColor(hex: "999999")
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = false
            }else{
                label.textColor = UIColor(hex: "6693ff")
                cell.selectionStyle = .default
                cell.isUserInteractionEnabled = true
            }
        }else{
            if wallet != nil{
                if wallet!.type == .address(wallet!.address){
                    label.textColor = UIColor(hex: "999999")
                    cell.selectionStyle = .none
                    cell.isUserInteractionEnabled = false
                }else{
                    label.textColor = UIColor(hex: "6693ff")
                    cell.selectionStyle = .default
                    cell.isUserInteractionEnabled = true
                }
            }else{
                label.textColor = UIColor(hex: "6693ff")
                cell.selectionStyle = .default
                cell.isUserInteractionEnabled = true
            }
        }

        return cell
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        //print("点击"+String(indexPath.section)+String(indexPath.row))
        
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        let psd = UserDefaults.standard.string(forKey: "passWord")

        if indexPath.row == 0 {

        }else if indexPath.row == 1 {
            if psd != nil{
                self.clickEvent(row: indexPath.row)
            }else{
                managerMainViewController.copyKeystory()
            }
        }else if indexPath.row == 2 {
            if psd != nil{
                self.clickEvent(row: indexPath.row)
            }else{
                managerMainViewController.export()
            }
        }else if indexPath.row == 3 {
            if psd != nil{
                self.clickEvent(row: indexPath.row)
            }else{
                managerMainViewController.copyAddress()
            }
        }else if indexPath.row == 4 {
            if psd != nil{
                self.clickEvent(row: indexPath.row)
            }else{
                managerMainViewController.delete()
            }
        }
        managerMainViewController.hideList()
    }
    
    @objc func clickEvent(row:NSInteger) {
        let psd = UserDefaults.standard.string(forKey: "passWord")

        UserDefaults.standard.set("isdelete", forKey: "isdelete")
        MyFinger.userFigerprintAuthenticationTipStr(withtips:"验证指纹") { (result:MyFinger.XWCheckResult) in
            switch result{
            case .success://情况没写全，需要的自己去看，我都列出来了
                print("用户解锁成功")
                DispatchQueue.main.async {
                    if row == 1{
                        self.managerMainViewController.copyKeystory()
                    }else if row == 2{
                        self.managerMainViewController.export()
                    }else if row == 3{
                        self.managerMainViewController.copyAddress()
                    }else if row == 4{
                        self.managerMainViewController.delete()
                    }
                }
                
                break
            case .failed:
                print("用户解锁失败")
                break
            case .passwordNotSet , .touchidNotSet , .touchidNotAvailable , .canclePer , .inputNUm:
                print("用户点击输入密码")
                DispatchQueue.main.async {
                    let payAlert = PayAlert(frame: UIScreen.main.bounds)
                    payAlert.titleLabel.text = "请输入密码"
                    payAlert.show(view: self.controller.view)
                    payAlert.completeBlock = ({(password:String) -> Void in
                        print("输入的密码是:" + password)
                        if password == psd {
                            payAlert.removeFromSuperview()
                            self.controller.view.removeFromSuperview()
                        }else{
                            payAlert.clearPSD()
                            payAlert.titleLabel.text = "密码错误，请重新输入密码"
                        }
                    })
                }
                break
            default:
                break
            }
        }
    }
    
    @objc func backCallback() {
        managerMainViewController.hideList()
    }
    
    @objc func becomeActive(){
        managerMainViewController.delete()
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
