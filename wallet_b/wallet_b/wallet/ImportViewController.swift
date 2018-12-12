//
//  ImportViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/4.
//  Copyright © 2018年 xhf. All rights reserved.
//

/*
 *导入钱包页面
 */
import UIKit
import TrustCore
import NVActivityIndicatorView

class ImportViewController: UIViewController,NVActivityIndicatorViewable {

    @IBOutlet weak var tipLab: UILabel!
    @IBOutlet weak var segMentedC: UISegmentedControl!
    @IBOutlet weak var infoTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var importBtn: UIButton!
    
    public var itemString:String = ""
    
//    let keystore: Keystore = EtherKeystore.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(itemString)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = LanguageHelper.getString(key: "import.bar.title")
        self.passwordTF.placeholder = LanguageHelper.getString(key: "请输入密码")
        self.importBtn.setTitle(LanguageHelper.getString(key: "import.bar.title"), for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        view.endEditing(true)
    }
    
    //展示不同选择
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        var placeholderTab = [ "Keystore JSON",LanguageHelper.getString(key: "import.peivate Key"),LanguageHelper.getString(key: "import.mnemonic"),LanguageHelper.getString(key: "import.watch")]
        self.infoTF.text = ""
        self.passwordTF.text = ""
        if sender.selectedSegmentIndex==0 {
            passwordTF.isHidden = false
        }else{
            passwordTF.isHidden = true
        }
        
        infoTF.placeholder = placeholderTab[sender.selectedSegmentIndex]
    }
    
   //导入钱包
    @IBAction func importCallback(_ sender: UIButton) {
        let type = segMentedC.selectedSegmentIndex

        switch type {
        case 0:
            if infoTF.text! == ""{
                alert(text: LanguageHelper.getString(key: "账号不能为空"))
                return
            }
            if passwordTF.text! == ""{
                alert(text: LanguageHelper.getString(key: "密码不能为空"))
                return
            }
        case 1:
            if infoTF.text! == ""{
                alert(text: LanguageHelper.getString(key: "私钥不能为空"))
                return
            }
        case 2:
            if infoTF.text! == ""{
                alert(text: LanguageHelper.getString(key: "请输入正确的地址"))
                return
            }
        case 3:
            guard Address(string: infoTF.text!) != nil else {
                alert(text: LanguageHelper.getString(key: "请输入正确的地址"))
                return
            }
        default:
            break
        }
        //根据不同类型导入
        let importType: ImportType = {
            switch type {
            case 0:
                return .keystore(string: infoTF.text!, password: passwordTF.text!)
            case 1:
                return .privateKey(privateKey: infoTF.text!)
            case 2:
                return .mnemonic(words: infoTF.text!.components(separatedBy:" ") , password: "")
            case 3:
                let address = Address(string: infoTF.text!)! // Address validated by form view.
                return .watch(address: address)
            default:
                let address = Address(string: infoTF.text!)! // Address validated by form view.
                return .watch(address: address)
            }
        }()

        startAnimating(CGSize(width: 30, height: 30), message: "Loading...", messageFont: nil, type: NVActivityIndicatorType.lineScale)
        keystore.importWallet(type: importType) { result in
            DispatchQueue.main.async {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
            switch result {
            case .success(let account):
                var wallets = UserDefaults.standard.dictionary(forKey: "wallets")
                var nameIndex = UserDefaults.standard.integer(forKey: "nameIndex")
                nameIndex = nameIndex+1
                UserDefaults.standard.set(nameIndex, forKey: "nameIndex")
                var name = LanguageHelper.getString(key: "以太坊钱包") + String(format: " %d",nameIndex)
                let img = Int(arc4random()%3)+1
                
                //初始化UITextField
                var inputText:UITextField = UITextField();
                let msgAlertCtr = UIAlertController.init(title: LanguageHelper.getString(key: "提示"), message: LanguageHelper.getString(key: "请输入昵称"), preferredStyle: .alert)
                let ok = UIAlertAction.init(title: LanguageHelper.getString(key: "确定"), style:.default) { (action:UIAlertAction) ->() in
                    if((inputText.text) != ""){
                        print("你输入的是：\(String(describing: inputText.text))")
                        name = inputText.text!
                        
                        
                        let walletInfo = ["name":name,"imgIndex":img] as [String : Any]
                        wallets![account.address.description] = walletInfo
                        UserDefaults.standard.set(wallets, forKey: "wallets")
                        
                        var rootVC = self.presentingViewController
                        while let parent = rootVC?.presentingViewController {
                            rootVC = parent
                        }
                        //释放所有下级视图
                        if let na = rootVC?.navigationController {
                            na.popToRootViewController(animated: false);
                        }else{
                            rootVC?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                let cancel = UIAlertAction.init(title: LanguageHelper.getString(key: "取消"), style:.cancel) { (action:UIAlertAction) -> ()in
                    print("取消输入")
                    
                    let walletInfo = ["name":name,"imgIndex":img] as [String : Any]
                    wallets![account.address.description] = walletInfo
                    UserDefaults.standard.set(wallets, forKey: "wallets")
                    
                    var rootVC = self.presentingViewController
                    while let parent = rootVC?.presentingViewController {
                        rootVC = parent
                    }
                    //释放所有下级视图
                    if let na = rootVC?.navigationController {
                        na.popToRootViewController(animated: false);
                    }else{
                        rootVC?.dismiss(animated: true, completion: nil)
                    }
                }
                msgAlertCtr.addAction(ok)
                msgAlertCtr.addAction(cancel)
                //添加textField输入框
                msgAlertCtr.addTextField { (textField) in
                    //设置传入的textField为初始化UITextField
                    inputText = textField
                    inputText.placeholder = "输入数据"
                }
                //设置到当前视图
                self.present(msgAlertCtr, animated: true, completion: nil)
                
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
    
    
     /*
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
