//
//  SelectionTableViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/23.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
//选择网络页面
class SelectionTableViewController: UITableViewController {
    var settingViewModel: SettingsViewModel!
    var showType = 0
    var config = Config()
    var settingViewController: SettingViewController!
    let languageTab = ["简体中文", "English"]
    
    var imageNil:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        let view = UIView()
        view.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        if self.showType == 0 {
            self.title = LanguageHelper.getString(key: "选择网络")
        }else if self.showType == 1{
            self.title = LanguageHelper.getString(key: "选择语言")
        }else{
            self.title = LanguageHelper.getString(key: "选择货币")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.showType == 0 {
            return settingViewModel.servers.count
        }else if self.showType == 1{
            return languageTab.count
        }else{
            return Currency.allValues.count
        }
    }
    
    override func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
        if self.showType==0 {
            cell.textLabel?.text = settingViewModel.servers[indexPath.row].displayName
            if settingViewModel.servers[indexPath.row].displayName == RPCServer(chainID: config.chainID).displayName{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }else if self.showType == 1{
            cell.textLabel?.text = languageTab[indexPath.row]
            if LanguageHelper.getString(key: "setting.language") == languageTab[indexPath.row]{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }else{
            let value = Currency.allValues[indexPath.row]
            let currencyCode = value.rawValue
            cell.textLabel?.text = currencyCode + " - " + (NSLocale.current.localizedString(forCurrencyCode: currencyCode) ?? "")

            if Currency.allValues[indexPath.row].rawValue == config.currency.rawValue{
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        if self.showType==0 {
            let server = settingViewModel.servers[indexPath.row]
            var config = mainTabBarController.session.config
            config.chainID = server.chainID
            mainTabBarController.changeInfo(for: mainTabBarController.session.account)
            self.navigationController?.popViewController(animated: true)
        }else if self.showType==1 {
            let l =  LanguageHelper.getString(key: LanguageHelper.getString(key: languageTab[indexPath.row]))
            LanguageHelper.shareInstance.setLanguage(langeuage: l)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
            self.navigationController?.popToRootViewController(animated: false)
            mainTabBarController.changeItem()
//            mainTabBarController.dismiss(animated: false, completion: nil)
        }else{
            let value = Currency.allValues[indexPath.row]
            var config = mainTabBarController.session.config
            config.currency = value
            mainTabBarController.changeInfo(for: mainTabBarController.session.account)
            self.navigationController?.popViewController(animated: true)
        }
        
    }


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
