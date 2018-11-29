//
//  SettingViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/23.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import WebKit

class SettingViewController: UITableViewController {
    var wallet:Wallet!
    var session:WalletSession!
    var balanceCoordinator:TokensBalanceService!
    var viewModel:SettingsViewModel!
    var config = Config()
    let titleTab = [["网络", "钱包", "地址簿"],["密码/TouchID", "推送通知"],["货币", "语言", "分享", "关于"],["清除缓存"]]
    
    @IBOutlet weak var psdSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        config = mainTabBarController.config
        self.viewModel = mainTabBarController.getSettingsViewModel(for: self)
        self.title = LanguageHelper.getString(key: "设置")
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "passWordView") as! PassWordViewController
            controller.showType = 1
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            UserDefaults.standard.removeObject(forKey: "passWord")
        }
    }
    
    func removeWKWebViewCookies(){
        
        //iOS9.0以上使用的方法
        if #available(iOS 9.0, *) {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) in
                for record in records{
                    //清除本站的cookie
                    //if record.displayName.contains("sina.com"){//这个判断注释掉的话是清理所有的cookie
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                        //清除成功
                        print("清除成功\(record)")
                    })
                    // }
                }
            })
        } else {
            //ios8.0以上使用的方法
            let libraryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
            let cookiesPath = libraryPath! + "/Cookies"
            try!FileManager.default.removeItem(atPath: cookiesPath)
        }
    }
    
    func ClearCache() {
        
        let dateFrom: NSDate = NSDate.init(timeIntervalSince1970: 0)
        
        if #available(iOS 9.0, *) {
            let websiteDataTypes: NSSet = WKWebsiteDataStore.allWebsiteDataTypes() as NSSet
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: dateFrom as Date) {
                print("清空缓存完成")
            }
        } else {
            let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
            let cookiesFolderPath = String(format: "%@%@", libraryPath,"/Cookies")
//            let errors: NSError
            try? FileManager.default.removeItem(atPath: cookiesFolderPath)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        //print("点击"+String(indexPath.section)+String(indexPath.row))
        
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = SelectionTableViewController()
                vc.showType = 0
                vc.settingViewModel = self.viewModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 1 {
                let vc = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "MainWalletManage")
                //vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
            if indexPath.row == 2 {
                let vc = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "AddressBookView")
                //vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
        if indexPath.section == 2 {
            if indexPath.row == 1 {
                let vc = SelectionTableViewController()
                vc.showType = 1
                vc.settingViewModel = self.viewModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 0 {
                let vc = SelectionTableViewController()
                vc.showType = 2
                vc.settingViewModel = self.viewModel
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if indexPath.row == 3 {
                let vc = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "AboutView")
                //vc.modalTransitionStyle = .crossDissolve
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                //removeWKWebViewCookies()
                ClearCache()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)-> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text =  LanguageHelper.getString(key: titleTab[indexPath.section][indexPath.row]) 
        if indexPath.section==1 && indexPath.row==0 {
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            cell.imageView?.image = R.image.icon_password()
            
            let psd = UserDefaults.standard.string(forKey: "passWord")
            if psd != nil {
                psdSwitch.isOn = true
            }else{
                psdSwitch.isOn = false
            }
        }
        if indexPath.section==0 {
            if indexPath.row == 0{
                cell.detailTextLabel?.text = RPCServer(chainID: config.chainID).displayName
            }
            if indexPath.row == 1{
                cell.detailTextLabel?.text = String(format: "%@...",String(self.wallet.address.description.prefix(10)))
            }
        }
        
        if indexPath.section==2 {
            if indexPath.row == 0{
                //设置-货币
                let value = self.config.currency
                let currencyCode = value.rawValue
                cell.detailTextLabel?.text = currencyCode + " - " + (NSLocale.current.localizedString(forCurrencyCode: currencyCode) ?? "")
            }
            if indexPath.row == 1{
                cell.detailTextLabel?.text = LanguageHelper.getString(key: "setting.language");
            }
        }
        
        return cell

    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Hello"
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
