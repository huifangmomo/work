//
//  ManagerMainViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/31.
//  Copyright © 2018年 xhf. All rights reserved.
//

import TrustCore
import UIKit
import PromiseKit

class ManagerMainViewController: UIViewController {
    
    var walletManagerNa:UINavigationController!
    var walletManageViewController:WalletManageViewController!
    
    var walletSettingViewController:WalletSettingViewController!
    
    var blurView:UIVisualEffectView!
    
    var statusBarStyle = UIStatusBarStyle.default
    
    var wallets: [Wallet] = []
    var balances: [Address: Balance?] = [:]
    var addrNames: [Address: String] = [:]
    //    var keystore: Keystore?
    var ensManager: ENSManager!
    var balanceCoordinator: TokensBalanceService!
    var config: Config = .current
    
    var walletsInfo = [String:Any]()
    
    var selectIndexPath:IndexPath?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        return self.statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //初始化主视图
        walletManagerNa = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WalletManageNa")
            as! UINavigationController



        //首先创建一个模糊效果
        let blurEffect = UIBlurEffect(style: .light)
        //接着创建一个承载模糊效果的视图
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.5
        //设置模糊视图的大小（全屏）
        blurView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        //添加模糊视图到页面view上（模糊视图下方都会有模糊效果）
        walletManagerNa.view.addSubview(blurView)
        blurView.isHidden = true
//
        walletManageViewController = walletManagerNa.viewControllers.first
            as! WalletManageViewController
        walletManageViewController.managerMainViewController = self

        self.view.addSubview(walletManagerNa.view)
//
        walletSettingViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "walletSetting")
            as! WalletSettingViewController
        self.view.addSubview(walletSettingViewController.view)
        walletSettingViewController.view.isHidden = true;
        walletSettingViewController.managerMainViewController = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(handleTapGesture))
        walletSettingViewController.touchView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.balanceCoordinator = mainTabBarController.balanceCoordinator
        self.ensManager = mainTabBarController.ensManager
        
        self.upDataView()
    }
    
    func upDataView() {
        walletsInfo = UserDefaults.standard.dictionary(forKey: "wallets")!
        var array = keystore.wallets
        for index in 0..<array.count{
            if array[index] == keystore.recentlyUsedWallet{
                array.remove(at: index)
                break
            }
        }
        array.insert(keystore.recentlyUsedWallet!, at: 0)
        wallets = array
        refreshWalletBalances()
        refreshENSNames()
        self.walletManageViewController.tableView.reloadData()
    }
    
    func refreshWalletBalances() {
        let addresses = wallets.compactMap { $0.address }
        var counter = 0
        for address in addresses {
            balanceCoordinator?.getEthBalance(for: address, completion: { [weak self] (result) in
                self?.balances[address] = result.value
                counter += 1
                if counter == addresses.count {
                    self?.walletManageViewController.tableView.reloadData()
                }
            })
        }
    }
    
    private func refreshENSNames() {
        let addresses = wallets.compactMap { $0.address }
        let promises =  addresses.map { ensManager.lookup(address: $0) }
        _ = when(fulfilled: promises).done { [weak self] names in
            for (index, name) in names.enumerated() {
                self?.addrNames[addresses[index]] = name
            }
            self?.walletManageViewController.tableView.reloadData()
            }.catch { error in
                print(error)
        }
    }
    
    func getAccountViewModels(for path: IndexPath) -> AccountViewModel {
        let account = self.wallet(for: path)! // Avoid force unwrap
        let balance = self.balances[account.address].flatMap { $0 }
        let ensName = self.addrNames[account.address] ?? ""
        let model = AccountViewModel(server: config.server, wallet: account, current: EtherKeystore.current, walletBalance: balance, ensName: ensName)
        return model
    }
    
    func wallet(for indexPath: IndexPath) -> Wallet? {
        return wallets[indexPath.row]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //单击手势响应
    @objc func handleTapGesture(_ tapGes : UITapGestureRecognizer) {
        //        print(tapGes.location(in: view).y)
        //        if tapGes.location(in: view).y<self.view.frame.height-changViewHeight {
        self.hideList()
        //        }
    }
    
    func showList(row:NSInteger) {
        blurView.isHidden = false
        blurView.alpha = 0
        self.walletSettingViewController.tableView.reloadData()
        self.statusBarStyle = UIStatusBarStyle.lightContent
        self.setNeedsStatusBarAppearanceUpdate()
        self.walletSettingViewController.view.center.y = self.view.frame.height/2 + 220
        self.walletSettingViewController.view.isHidden = false
        self.walletSettingViewController.wallet = wallets[row]
        doTheAnimate(mainPosition: self.view.frame.height/2,blurAlpha:0.7, mainProportion: 0.93,
                     blackCoverAlpha: 1) {
                        finished in
        }
    }
    
    func hideList() {
        doTheAnimate(mainPosition: self.view.frame.height/2+220,blurAlpha:0,mainProportion: 1,
                     blackCoverAlpha: 1) {
                        finished in
                        self.walletSettingViewController.view.isHidden = true
                        self.blurView.isHidden = true
                        self.statusBarStyle = UIStatusBarStyle.default
                        self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func doTheAnimate(mainPosition: CGFloat, blurAlpha: CGFloat, mainProportion: CGFloat,
                      blackCoverAlpha: CGFloat, completion: ((Bool) -> Void)! = nil) {
        //usingSpringWithDamping：1.0表示没有弹簧震动动画
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                        self.blurView.alpha = blurAlpha
                        self.walletSettingViewController.view.center.y = mainPosition
                        self.walletManagerNa.view.transform =
                            CGAffineTransform.identity.scaledBy(x: mainProportion, y: mainProportion)
        }, completion: completion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)  {
        view.endEditing(true)
    }
    
    func actionBack() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func delete() {
        let wallet = self.wallet(for: selectIndexPath!)!
        //navigationController?.displayLoading(text: NSLocalizedString("Deleting", value: "Deleting", comment: ""))
        keystore.delete(wallet: wallet) { [weak self] result in
            guard let `self` = self else { return }
            //self.navigationController?.hideLoading()
            switch result {
            case .success:
                var array = UserDefaults.standard.dictionary(forKey: "wallets")!
                if array[wallet.address.description] != nil {
                    array.removeValue(forKey: wallet.address.description)
                }
                UserDefaults.standard.set(array, forKey: "wallets")
                self.upDataView()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func copyKeystory() {
        let wallet = self.wallet(for: selectIndexPath!)!
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "passNa") as! UINavigationController
        let vc = controller.viewControllers.first as! PassWordTableViewController
        switch wallet.type {
        case .privateKey(let account), .hd(let account):
            vc.presentViewController = self
            vc.account = account
        case .address:
            // This case should be returning an error inCoordinator. Improve this logic into single piece.
            break
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func export() {
        
        let wallet = self.wallet(for: selectIndexPath!)!
        switch wallet.type {
        case .privateKey(let account), .hd(let account):
            do {
                let key = try keystore.exportPrivateKey(account: account).dematerialize()
                self.walletManageViewController.exportKey(str: key.hexString)
            } catch {
                print("出错了")
            }
        case .address:
            // This case should be returning an error inCoordinator. Improve this logic into single piece.
            break
        }
    }
    
    func copyAddress() {
        let wallet = self.wallet(for: selectIndexPath!)!
        UIPasteboard.general.string = wallet.address.description
        alert(text: LanguageHelper.getString(key: "已经复制钱包地址到剪贴板"))
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
