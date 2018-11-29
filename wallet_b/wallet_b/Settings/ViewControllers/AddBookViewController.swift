//
//  AddBookViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/8/1.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import QRCodeReaderViewController

class AddBookViewController: UITableViewController,QRCodeReaderDelegate,UITextFieldDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var info: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    var bookIndex:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        var books = UserDefaults.standard.array(forKey: "books")
        if (bookIndex != nil) {
            let book = books![bookIndex!] as! [String:String]
            name.text = book["name"]
            info.text = book["info"]
            address.text = book["address"]
        }
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = LanguageHelper.getString(key: "添加地址")
        self.name.placeholder = LanguageHelper.getString(key: "名称")
        self.info.placeholder = LanguageHelper.getString(key: "备注（选填）")
        self.address.placeholder = LanguageHelper.getString(key: "请输入有效的地址")
        self.saveBtn.setTitle(LanguageHelper.getString(key: "保存"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func scanCallback(_ sender: UIButton) {
        openReader()
    }
    
    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
        
        guard let result = QRURLParser.from(string: result) else {
            alert(text: LanguageHelper.getString(key: "不是钱包"))
            return
        }
        
        self.address.text = result.address
    }
    
    @IBAction func saveCallback(_ sender: UIButton) {
        if name.text == "" || address.text == "" {
            alert(text: LanguageHelper.getString(key: "名称和地址都不能为空"))
            return
        }
        if CryptoAddressValidator.isValidAddress(address.text) {
            
        }else{
            alert(text: LanguageHelper.getString(key: "请输入有效的地址"))
            return
        }
        var books = UserDefaults.standard.array(forKey: "books")
        let book = ["name":name.text,"info":info.text,"address":address.text] as! [String : String]
        if (bookIndex != nil) {
            books![bookIndex!] = book
        }else{
            books?.append(book)
        }
        UserDefaults.standard.set(books, forKey: "books")
        self.navigationController?.popViewController(animated: true)
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
    // MARK: - Table view data source

    override func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
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
