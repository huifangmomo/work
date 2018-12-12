//
//  CreateViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/4.
//  Copyright © 2018年 xhf. All rights reserved.
//
/*
 *创建钱包页面
 */
import UIKit
import TrustKeystore
import NVActivityIndicatorView

class CreateViewController: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var warnLab: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordTF_sec: UITextField!
    @IBOutlet weak var promptTF: UITextField!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var serviceBtn: UIButton!
    @IBOutlet weak var importBtn: UIButton!
        
    var isSelected = true
    let keystore: Keystore = EtherKeystore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        checkBtn.setImage(R.image.btn_tick_2(), for: UIControlState.normal)
        isSelected = true        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = LanguageHelper.getString(key: "create.bar.title")
        let str = LanguageHelper.getString(key: "create.warn")
        //富文本
        warnLab.attributedText  = self .getAttributeStringWithString(str, lineSpace: 5.00)
        self.nameTF.placeholder = LanguageHelper.getString(key: "钱包名称");
        self.createBtn.setTitle(LanguageHelper.getString(key: "create.bar.title"), for: .normal)
        self.importBtn.setTitle(LanguageHelper.getString(key: "import.bar.title"), for: .normal)
        self.serviceBtn.setTitle(LanguageHelper.getString(key: "服务及隐私条款"), for: .normal)
        self.checkBtn.setTitle(LanguageHelper.getString(key: "我已经仔细阅读并同意"), for: .normal)
    }
    
    fileprivate func getAttributeStringWithString(_ string: String,lineSpace:CGFloat
        ) -> NSAttributedString{
        let attributedString = NSMutableAttributedString(string: string)
        let paragraphStye = NSMutableParagraphStyle()
        
        //调整行间距
        paragraphStye.lineSpacing = lineSpace
        let rang = NSMakeRange(0, CFStringGetLength(string as CFString?))
        attributedString .addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStye, range: rang)
        return attributedString
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        view.endEditing(true)
    }
    

    @IBAction func checkCallback(_ sender: UIButton) {
        if isSelected == true {
            checkBtn.setImage(R.image.btn_tick_1(), for: UIControlState.normal)
            isSelected = false
        }else{
            checkBtn.setImage(R.image.btn_tick_2(), for: UIControlState.normal)
            isSelected = true
        }
        print(isSelected)
    }
    
    @IBAction func serviceInfoCallback(_ sender: UIButton) {
        print("服务条款")
    }
    
    @IBAction func createCallback(_ sender: UIButton) {
        //创建钱包
        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
        let password = PasswordGenerator.generateRandom()
        keystore.createAccount(with: password) { result in
            DispatchQueue.main.async {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
            switch result {
            case .success(let account):
                self.keystore.exportMnemonic(account: account, completion: { mnemonicResult in
                    switch mnemonicResult {
                    case .success(let words):
                        print(words)
                    case .failure(let error):
                        print(error)
                    }
                })
                
                var wallets = UserDefaults.standard.dictionary(forKey: "wallets")
                var nameIndex = UserDefaults.standard.integer(forKey: "nameIndex")
                nameIndex = nameIndex+1
                UserDefaults.standard.set(nameIndex, forKey: "nameIndex")
                var name = self.nameTF.text
                if self.nameTF.text == ""{
                    name = LanguageHelper.getString(key: "以太坊钱包") + String(format: " %d",nameIndex)
                }
                
                let img = Int(arc4random()%3)+1
                let walletInfo = ["name":name!,"imgIndex":img] as [String : Any]
                wallets![account.address.description] = walletInfo
                UserDefaults.standard.set(wallets, forKey: "wallets")
                self.performSegue(withIdentifier: "createToCopy", sender: account)
            case .failure(let error):
                self.alert(text: error.errorDescription!)
            }
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createToCopy"{
            let controller = segue.destination as! CopyViewController
            controller.account = sender as! Account
        }
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
