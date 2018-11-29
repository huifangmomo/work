//
//  ViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/3.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

var keystore: Keystore = EtherKeystore.shared
let current: Config = Config()
var mainTabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabBarController") as! TabBarController

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLanguage), name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
        
        label?.text = LanguageHelper.getString(key: "welcome.title1")
        
        var wallets = UserDefaults.standard.dictionary(forKey: "wallets")
        if(wallets != nil){
            
        }else{
            wallets = [String:Any]() 
            UserDefaults.standard.set(wallets, forKey: "wallets")
        }
        
        var books = UserDefaults.standard.array(forKey: "books")
        if(books != nil){
            
        }else{
            books = []
            UserDefaults.standard.set(books, forKey: "books")
        }
        
        var nameIndex = UserDefaults.standard.integer(forKey: "nameIndex")
        if(nameIndex >= 0){
            
        }else{
            nameIndex = 0
            UserDefaults.standard.set(nameIndex, forKey: "nameIndex")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(keystore)
        if keystore.hasWallets {
            mainTabBarController.changeInfo(for: keystore.recentlyUsedWallet ?? keystore.wallets.first!)
            mainTabBarController.selectedIndex = 2
            self.present(mainTabBarController, animated: true, completion: nil)
            //self.performSegue(withIdentifier: "BeginToMain", sender: "跳转去主页")
        } else {
            self.performSegue(withIdentifier: "BeginToWelcome", sender: "跳转去欢迎页")
        }
    }
    
    @objc func changeLanguage() -> Void {
        label?.text = LanguageHelper.getString(key: "welcome.title1")
        print("刷新界面")
        
    }
    
    @IBAction func toC(_ sender: UIButton) {
        LanguageHelper.shareInstance.setLanguage(langeuage: "zh-Hans")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
    }
    
    @IBAction func toE(_ sender: UIButton) {
        LanguageHelper.shareInstance.setLanguage(langeuage: "en")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LanguageChanged"), object: nil)
    }
    
    
    @IBAction func toW(_ sender: UIButton) {
        self.performSegue(withIdentifier: "BeginToWelcome", sender: "跳转去欢迎页")
    }
    
    @IBAction func toM(_ sender: UIButton) {
        self.performSegue(withIdentifier: "BeginToMain", sender: "跳转去主页")
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BeginToWelcome"{
            let controller = segue.destination as! UINavigationController
            let vc = controller.viewControllers.first as! WelcomeViewController
            vc.backBtn.isHidden = true
            //controller.itemString = sender as? String
            
            print(sender as? String as Any)
        }
        if segue.identifier == "BeginToMain"{
            
            let controller = segue.destination as! UITabBarController
            //controller.itemString = sender as? String
            controller.selectedIndex = 1
            
            print(sender as? String as Any)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

