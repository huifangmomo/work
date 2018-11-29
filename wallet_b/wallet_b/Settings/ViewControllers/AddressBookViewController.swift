//
//  AddressBookViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/8/1.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class AddressBookViewController: UITableViewController {

    var books: Array<Any>!
    var presentViewController: TransferTableViewController?
    var imageNil:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        books = UserDefaults.standard.array(forKey: "books")
        tableView.register(UINib(nibName: "AddressBookCell", bundle: nil), forCellReuseIdentifier: "AddressBookCell")
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        books = UserDefaults.standard.array(forKey: "books")
        self.title = LanguageHelper.getString(key: "地址簿")
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backCallback(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addCallback(_ sender: Any) {
        self.performSegue(withIdentifier: "bookToAdd", sender: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if books.count == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
        return books.count
    }
    
    override func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }
    
    override func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookCell") as! AddressBookCell
        let book = books[indexPath.row] as! [String:String]
        cell.name.text = book["name"]
        cell.info.text = book["info"]
        cell.address.text = book["address"]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?{
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            books.remove(at: indexPath.row)
            UserDefaults.standard.set(books, forKey: "books")
            //刷新tableview
            //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        //print("点击"+String(indexPath.section)+String(indexPath.row))
        
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        
        if self.presentViewController != nil {
            let book = books[indexPath.row] as! [String:String]
            self.dismiss(animated: true, completion: {
                self.presentViewController!.toAddressValue.text = book["address"]
            })
        }else{
             self.performSegue(withIdentifier: "bookToAdd", sender: indexPath.row)
        }
       
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "bookToAdd"{
            let controller = segue.destination as! AddBookViewController
            controller.bookIndex = sender as? Int
        }
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
