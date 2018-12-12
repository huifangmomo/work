//
//  PassWordTableViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/27.
//  Copyright © 2018年 xhf. All rights reserved.
//

import Foundation
import UIKit
import Result
import TrustCore
import TrustKeystore
import NVActivityIndicatorView

class PassWordTableViewController: UITableViewController,NVActivityIndicatorViewable {
    var account: Account!
    @IBOutlet weak var passWord_1: UITextField!
    @IBOutlet weak var passWord_2: UITextField!
    
    var presentViewController: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        print(account)
//        let wallets = UserDefaults.standard.dictionary(forKey: "wallets")
//        print(wallets as Any)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeDeath), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)

    }
    
    @IBAction func becomeActive(_ sender: UIBarButtonItem) {
        print("becomeActive")
    }
    
    @IBAction func becomeDeath(_ sender: UIBarButtonItem) {
        print("becomeDeath")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        self.title = LanguageHelper.getString(key: "备份 Keystore")
        passWord_1.placeholder = LanguageHelper.getString(key: "密码")
        passWord_2.placeholder = LanguageHelper.getString(key: "确认密码")
        tableView.reloadData()
    }

    
    @IBAction func backCallback(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneCallback(_ sender: UIBarButtonItem) {
        if self.passWord_1.text=="" || self.passWord_2.text==""{
            alert(text: LanguageHelper.getString(key: "密码不能为空"))
            return
        }
        if self.passWord_1.text != self.passWord_2.text{
            alert(text: LanguageHelper.getString(key: "两次输入的密码不一致"))
            return
        }
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
        if let currentPassword = keystore.getPassword(for: account) {
            print(currentPassword)
            keystore.export(account: account, password: currentPassword, newPassword: self.passWord_1.text!) { result in
                self.handleExport(result: result){ result in
                    //self.finish(result: result)
                    //获取根视图
                    var rootVC = self.presentingViewController
                    if (self.presentViewController != nil) {
                        rootVC = self.presentViewController
                    }else{
                        while let parent = rootVC?.presentingViewController {
                            rootVC = parent
                        }
                        //释放所有下级视图
                    }
                   
                    if let na = rootVC?.navigationController {
                        na.popToRootViewController(animated: false);
                    }else{
                        rootVC?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            print("没密码")
            keystore.export(account: account, password: self.passWord_1.text!, newPassword: self.passWord_2.text!) { result in
                self.handleExport(result: result){ result in
                    //self.finish(result: result)
                }

            }
        }
    }
    
    private func handleExport(result: (Result<String, KeystoreError>), completion:  @escaping (Result<Bool, AnyError>) -> Void) {
        DispatchQueue.main.async {
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        switch result {
        case .success(let value):
            let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("keystore_backup_\(account.address.description).json"))
            do {
                try value.data(using: .utf8)!.write(to: url)
            } catch {
                return completion(.failure(AnyError(error)))
            }
            
            let activityViewController = UIActivityViewController.make(items: [url])
            activityViewController.completionWithItemsHandler = { _, result, _, error in
                do {
                    try FileManager.default.removeItem(at: url)
                } catch { }
                guard let error = error else {
                    return completion(.success(result))
                }
                completion(.failure(AnyError(error)))
            }
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.popoverPresentationController?.sourceRect =  self.view.frame
            self.present(activityViewController, animated: true) { [unowned self] in
                
            }
        case .failure(let error):
            self.alert(text: error.errorDescription!)
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
        return 2
    }
    
    override func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
        return 20
    }
    
    override func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 34
    }
    
    override func tableView(_ tableView:UITableView, viewForFooterInSection section:Int) ->UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "fafafa")
        let titleLabel = UILabel(frame: CGRect(x:16, y:10,width:self.view.bounds.size.width-15, height:24))
        titleLabel.text = LanguageHelper.getString(key: "密码用来加密你的备份文件，请确保它的安全！")
        titleLabel.textColor = UIColor(hex: "666666")
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    override func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 44
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        view.endEditing(true)
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
