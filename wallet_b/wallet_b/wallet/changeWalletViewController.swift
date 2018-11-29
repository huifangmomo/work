//
//  changeWalletViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/9.
//  Copyright © 2018年 xhf. All rights reserved.
//

import TrustCore
import UIKit
import PromiseKit

class changeWalletViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewHight: NSLayoutConstraint!
    @IBOutlet weak var walletTableView: UITableView!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var createBtn: UIButton!
    var mainWalletViewController:MainWalletViewController!
    
    var wallets: [Wallet] = []
    var balances: [Address: Balance?] = [:]
    var addrNames: [Address: String] = [:]
//    var keystore: Keystore?
    var ensManager: ENSManager!
    var balanceCoordinator: TokensBalanceService!
    var config: Config = .current
    
    var walletsInfo = [String:Any]()
    var imageNil:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.walletTableView.dataSource = self
        self.walletTableView.delegate = self
        self.walletTableView.register(UINib(nibName: "walletCell", bundle: nil), forCellReuseIdentifier: "walletCell")
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
    }
    
    @IBAction func addWalletCallback(_ sender: UIButton) {
        mainWalletViewController.toWelcome()
    }
    
    func show() {
        self.createBtn.setTitle( LanguageHelper.getString(key: "创建钱包"), for:.normal)
        walletsInfo = UserDefaults.standard.dictionary(forKey: "wallets")!

        wallets = keystore.wallets
//        let hdWallets = wallets.filter { wallet in
//            switch wallet.type {
//            case .hd: return true
//            case .privateKey, .address: return false
//            }
//        }
//        let regularWallets = wallets.filter { wallet in
//            switch wallet.type {
//            case .privateKey, .address:
//                return true
//            case .hd: return false
//            }
//        }
//        print(regularWallets)
        refreshWalletBalances()
        refreshENSNames()
        self.walletTableView.reloadData()
    }
    
    func refreshWalletBalances() {
        let addresses = wallets.compactMap { $0.address }
        var counter = 0
        for address in addresses {
            balanceCoordinator?.getEthBalance(for: address, completion: { [weak self] (result) in
                self?.balances[address] = result.value
                counter += 1
                if counter == addresses.count {
                    self?.walletTableView.reloadData()
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
            self?.walletTableView.reloadData()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if wallets.count == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
        return wallets.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "walletCell") as! walletCell
        let model = getAccountViewModels(for: indexPath)
        cell.address.text = model.title
        cell.balance.text = model.balanceText
        if walletsInfo[model.wallet.address.description] != nil {
            if let info = walletsInfo[model.wallet.address.description] as? [String : Any]{
                if info["name"] != nil {
                    cell.name.text = info["name"] as? String
                }else{
                    cell.name.text = "以太坊钱包1"
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
                cell.name.text = walletsInfo[model.wallet.address.description] as? String
            }
        }else{
            cell.name.text = "以太坊钱包1"
        }
        if model.isActive {
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 60
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        guard let wallet = self.wallet(for: indexPath) else { return }
        mainWalletViewController.upDataTokens(for:wallet)
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
