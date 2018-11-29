//
//  WalletManageViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/30.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class WalletManageViewController: UITableViewController {
    var managerMainViewController:ManagerMainViewController!
    
    var imageNil:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.register(UINib(nibName: "walletManageCell", bundle: nil), forCellReuseIdentifier: "walletManageCell")
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.title = LanguageHelper.getString(key: "钱包")
        self.tableView.reloadData()
    }
    
    @IBAction func goBackCallback(_ sender: UIButton) {
        managerMainViewController.actionBack()
    }
    
    func exportKey(str: String) {
        self.performSegue(withIdentifier: "walletsToExport", sender: str)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "walletsToExport"{
            let controller = segue.destination as! ExportPeivateKeyViewController
            let str = sender as! String
            controller.str = str
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
        if managerMainViewController.wallets.count == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
        return managerMainViewController.wallets.count
    }
    
    override func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }
    
    override func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = managerMainViewController.getAccountViewModels(for: indexPath)
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletManageCell") as! walletManageCell
        cell.addressLab.text = String(format: "%@:%@...%@",model.symbol,String(model.wallet.address.description.prefix(10)), String(model.wallet.address.description.suffix(10)))
        cell.balanceLab.text = model.balanceText
    
        let walletsInfo = managerMainViewController.walletsInfo
        if walletsInfo[model.wallet.address.description] != nil {
            if let info = walletsInfo[model.wallet.address.description] as? [String : Any]{
                if info["name"] != nil {
                    cell.nameLab.text = info["name"] as? String
                }else{
                    cell.nameLab.text =  LanguageHelper.getString(key: "以太坊钱包") + "1"
                }
                if info["imgIndex"] != nil {
                    switch info["imgIndex"] as! Int {
                    case 1:
                        cell.img.image = R.image.icon_wallet_1()
                    case 2:
                        cell.img.image = R.image.icon_wallet_2()
                    case 3:
                        cell.img.image = R.image.icon_wallet_3()
                    case 4:
                        cell.img.image = R.image.icon_wallet_1()
                    default:
                        cell.img.image = R.image.icon_wallet_1()
                    }
                }
            }else{
                cell.nameLab.text = walletsInfo[model.wallet.address.description] as? String
            }
        }else{
            cell.nameLab.text = LanguageHelper.getString(key: "以太坊钱包") + "1"
        }
        
        if indexPath.row == 0 {
            cell.markImage.isHidden = false
        }else{
            cell.markImage.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        //print("点击"+String(indexPath.section)+String(indexPath.row))
        
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        managerMainViewController.selectIndexPath = indexPath
        
        managerMainViewController.showList(row: indexPath.row)
    }

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
