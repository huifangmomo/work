//
//  TokensViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/9.
//  Copyright © 2018年 xhf. All rights reserved.
//

import Foundation
import UIKit
import Result
import TrustCore
import RealmSwift
import Kingfisher
import Crashlytics
import QRCodeReaderViewController

//首页

class TokensViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,QRCodeReaderDelegate {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var walletImgView: UIImageView!
    @IBOutlet weak var walletName: UILabel!
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var walletMoney: UILabel!
    @IBOutlet weak var tokenTableView: UITableView!
    
    var mainWalletViewController:MainWalletViewController!
    
    var viewModel:TokensViewModel!
    
    var wallet:Wallet!
    var session:WalletSession!
    var tokensStorage:TokensDataStore!
    var trustNetwork:TrustNetwork!
    var transactionsStorage:TransactionsStorage!
    
    var rowMark:IndexPath?
    
    let refreshControl = UIRefreshControl()
    var etherFetchTimer: Timer?
    let intervalToETHRefresh = 10.0
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var tokenViewModel:TokenViewModel?
    var imageNil:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tokenTableView.register(UINib(nibName: "tokenCell", bundle: nil), forCellReuseIdentifier: "tokenCell")
//        tokenTableView.register(UINib(nibName: "tokenCell_2", bundle: nil), forCellReuseIdentifier: "tokenCell_2")
        let view = UIView()
        view.backgroundColor = UIColor.clear
        tokenTableView.tableFooterView = view
        tokenTableView.dataSource = self
        tokenTableView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tokenTableView.addSubview(refreshControl)
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
        
        let singleTap = UITapGestureRecognizer.init(target:self, action: #selector(handleSingleTap(tap:)))
        bgImage.addGestureRecognizer(singleTap)
        bgImage.isUserInteractionEnabled = true
        
        let button = UIButton(type:.custom)
        button.setTitle("ETH", for: .normal)
        button.setBackgroundImage(R.image.btn_switch_1(), for: .normal)
        button.setBackgroundImage(R.image.btn_switch_2(), for: .highlighted)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(changeNet), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    @objc private func handleSingleTap(tap:UITapGestureRecognizer) {
        UIPasteboard.general.string = self.viewModel.address.description
        print(self.viewModel.address.description)
        alert(text: LanguageHelper.getString(key: "已经复制钱包地址到剪贴板"))
    }
    
    @objc func changeNet(button : UIButton) {
        print("切换网络")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        //self.title = LanguageHelper.getString(key: "wallet.bar.title");
        mainWalletViewController.tabBarController?.tabBar.isHidden = false
        sheduleBalanceUpdate()
        startTokenObservation()
        fetch()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated) // No need for semicolon
        etherFetchTimer?.invalidate()
        etherFetchTimer = nil
        stopTokenObservation()
    }
    
    func startTokenObservation() {
//        viewModel.setTokenObservation { [weak self] (changes: RealmCollectionChange) in
//            guard let strongSelf = self else { return }
//            let tableView = strongSelf.tokenTableView
//            switch changes {
//            case .initial:
//                tableView?.reloadData()
//            case .update:
//                tableView?.reloadData()
//                //self?.endLoading()
//            case .error(let error):
//                print(error)
//                //self?.endLoading(animated: true, error: error, completion: nil)
//            }
//            if strongSelf.refreshControl.isRefreshing {
//                strongSelf.refreshControl.endRefreshing()
//            }
//      //      self?.refreshHeaderView()
//        }
    }
    
    private func stopTokenObservation() {
//        viewModel.invalidateTokensObservation()
    }
    
    private func sheduleBalanceUpdate() {
        guard etherFetchTimer == nil else { return }
        etherFetchTimer = Timer.scheduledTimer(timeInterval: intervalToETHRefresh, target: BlockOperation { [weak self] in self?.viewModel.updateEthBalance() }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }
    
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }
    
    func fetch() {
        viewModel = mainTabBarController.getTokensViewModel(for: self)
        walletMoney.text = viewModel.headerBalance
        let addressStr = wallet.address.description
        walletAddress.text = String(format: "(%@...%@)", String(addressStr.prefix(13)), String(addressStr.suffix(3)))
        let walletsInfo = UserDefaults.standard.dictionary(forKey: "wallets")!
        if walletsInfo[addressStr] != nil {
            if let info = walletsInfo[addressStr] as? [String : Any]{
                if info["name"] != nil {
                    walletName.text = info["name"] as? String
                }else{
                    walletName.text = "以太坊钱包1"
                }
                if info["imgIndex"] != nil {
                    switch info["imgIndex"] as! Int {
                    case 1:
                        walletImgView.image = R.image.icon_wallet_1()
                    case 2:
                        walletImgView.image = R.image.icon_wallet_2()
                    case 3:
                        walletImgView.image = R.image.icon_wallet_3()
                    case 4:
                        walletImgView.image = R.image.icon_wallet_1()
                    default:
                        walletImgView.image = R.image.icon_wallet_1()
                    }
                }
            }else{
                walletName.text = walletsInfo[addressStr] as? String
            }
        }else{
            walletName.text = "以太坊钱包1"
        }
        
        
        self.viewModel.fetch()
        tokenTableView.reloadData()
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    //首次进来拉到空数据
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel != nil {
            self.imageNil.isHidden = true
            return viewModel.tokens.count
        }else{
            self.imageNil.isHidden = false
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tokenViewCellViewModel = viewModel.cellViewModel(for: indexPath)
//        if (indexPath.row == 0)
//        {
        
//        TrustService.prices(currency: value.rawValue, symbols: tokenViewCellViewModel.title)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tokenCell") as! tokenCell
        cell.name.text = tokenViewCellViewModel.title
        cell.balance.text = tokenViewCellViewModel.amount
        cell.money.text = tokenViewCellViewModel.currencyAmount
        cell.percent.text = tokenViewCellViewModel.percentChange
        cell.percent.textColor = tokenViewCellViewModel.percentChangeColor
        cell.img.kf.setImage(
            with: tokenViewCellViewModel.imageUrl,
            placeholder: tokenViewCellViewModel.placeholderImage
        )
        
        return cell
//        }else{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "tokenCell_2") as! tokenCell_2
//            cell.name.text = tokenViewCellViewModel.title
//            cell.balance.text = tokenViewCellViewModel.amount
//            cell.img.kf.setImage(
//                with: tokenViewCellViewModel.imageUrl,
//                placeholder: tokenViewCellViewModel.placeholderImage
//            )
//            return cell
//        }
        
    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 80
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        tokenViewModel = TokenViewModel(token: viewModel.tokens[indexPath.row], store: tokensStorage, transactionsStore: transactionsStorage, tokensNetwork: trustNetwork, session: session)
        rowMark = indexPath
        self.performSegue(withIdentifier: "WalletToTransfer", sender: "跳转去转账")
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WalletToTransfer"{
            let controller = segue.destination as! TransferViewController
            controller.tabBarVc = mainWalletViewController.tabBarController
            controller.viewModel = tokenViewModel
            controller.wallet = wallet
            if rowMark?.row == 0{
                controller.paymentFlow = .send(type: .ether(destination: .none))
            }else{
                controller.paymentFlow = .send(type: .token(tokenViewModel!.token))
            }
            print(sender as? String as Any)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeWallet(_ sender: UIBarButtonItem) {
        print("changeWallet")
        mainWalletViewController.showList()
    }
    
    
    @IBAction func scanfClick(_ sender: UIBarButtonItem) {
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
        let viewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "transferMain") as! TransferMainViewController
        viewController.paymentFlow = .send(type: .ether(destination: .none))
        viewController.toAddressValueStr = result.address
        if (result.params["amount"] != nil) {
            viewController.sendValueStr = result.params["amount"]
        }else{
            viewController.sendValueStr = ""
        }
        viewController.tabBarVc = mainWalletViewController.tabBarController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    @IBAction func addTokenCallback(_ sender: UIButton) {
        let controller = EditTokensViewController(
            session: session,
            storage: tokensStorage,
            network: trustNetwork
        )
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func addToken() {
        let controller = newTokenViewController(token: .none)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(back))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func newTokenViewController(token: ERC20Token?) -> NewTokenViewController {
        let viewModel = NewTokenViewModel(token: token, tokensNetwork: trustNetwork)
        let controller = NewTokenViewController(token: token, viewModel: viewModel)
//        controller.delegate = self
        return controller
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
