//
//  TransferConfirmViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/16.
//  Copyright © 2018年 xhf. All rights reserved.
//

import BigInt
import Foundation
import APIKit
import JSONRPCKit
import Result

class TransferConfirmViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var touchView: UIView!
  
    var configurator: TransactionConfigurator!
    var session: WalletSession!
    var confirmType: ConfirmType!
    
    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "passWordView") as! PassWordViewController
    
    var transferMainViewController:TransferMainViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showCell_"+String(indexPath.row), for: indexPath)
        if indexPath.row == 5 {
            let btn = cell.viewWithTag(2) as! UIButton
            btn.setTitle(LanguageHelper.getString(key: "确认"), for: .normal)
            btn.addTarget(self,action:#selector(sureCallback),for:.touchUpInside)
            let lab_1 = cell.viewWithTag(3) as! UILabel
            let lab_2 = cell.viewWithTag(4) as! UILabel
            lab_1.text = LanguageHelper.getString(key: "金额")
            if (transferMainViewController != nil && configurator != nil) {
                let money = transferMainViewController.prices!
                lab_2.text = String(format: "%@%@",money,transferMainViewController.transferTableViewController.viewModel.symbol)
            }
        }
        if indexPath.row == 0 {
            let btn = cell.viewWithTag(2) as! UIButton
            btn.addTarget(self,action:#selector(backCallback),for:.touchUpInside)
        }
        if indexPath.row == 1 {
            let lab_1 = cell.viewWithTag(2) as! UILabel
            let lab_2 = cell.viewWithTag(3) as! UILabel
            lab_1.text = LanguageHelper.getString(key: "订单信息")
            lab_2.text = LanguageHelper.getString(key: "转账")
            
            if (transferMainViewController.dappTransaction != nil){
                 lab_2.text = LanguageHelper.getString(key: "dapp")
            }
        }
        if indexPath.row == 2 {
            let lab_1 = cell.viewWithTag(2) as! UILabel
            let lab_2 = cell.viewWithTag(3) as! UILabel
            lab_1.text = LanguageHelper.getString(key: "收款地址")
            if (configurator != nil) {
                lab_2.text = configurator.transaction.to?.description ?? ""
            }
        }
        if indexPath.row == 3 {
            let lab_1 = cell.viewWithTag(2) as! UILabel
            let lab_2 = cell.viewWithTag(3) as! UILabel
            lab_1.text = LanguageHelper.getString(key: "付款地址")
            if (session != nil) {
                lab_2.text = session.account.address.description
            }
        }
        if indexPath.row == 4 {
            let lab_1 = cell.viewWithTag(2) as! UILabel
            let lab_2 = cell.viewWithTag(3) as! UILabel
            let lab_3 = cell.viewWithTag(4) as! UILabel
            lab_1.text = LanguageHelper.getString(key: "矿工费用")
            if (transferMainViewController != nil && configurator != nil) {
                let gasPriceGwei = EtherNumberFormatter.full.string(from: configurator.transaction.gasPrice!, units: UnitConfiguration.gasPriceUnit)
                lab_2.text = transferMainViewController.transferTableViewController.estimatedFeeText
                lab_3.text = String(format: "≈Gas(%@)*Gas Price(%@gwei)",(configurator.transaction.gasLimit?.description)!,gasPriceGwei)
            }
        }
        return cell
    }
    
    func upDateView() {
        tableView.reloadData()
    }
    
    @objc func backCallback() {
        transferMainViewController.hideList()
    }
    
    @objc func sureCallback() {
        print("确认")
        let psd = UserDefaults.standard.string(forKey: "passWord")
        if psd != nil{
            UserDefaults.standard.set("isdelete", forKey: "isdelete")
            MyFinger.userFigerprintAuthenticationTipStr(withtips:"验证指纹") { (result:MyFinger.XWCheckResult) in
                switch result{
                case .success://情况没写全，需要的自己去看，我都列出来了
                    print("用户解锁成功")
                    DispatchQueue.main.async {
                        let transaction = self.configurator.signTransaction
                        self.send(transaction: transaction) { [weak self] result in
                            guard let `self` = self else { return }
                            
                            if (self.transferMainViewController.dappTransaction != nil){
                                self.transferMainViewController.didCompleted!(result)
                            }else{
                                switch result {
                                case .success(let type):
                                    switch type {
                                    case .sentTransaction(let transaction):
                                        var useData = self.configurator.signTransaction.data
                                        mainTabBarController.addSentTransaction(transaction)
                                        self.transferMainViewController.hideList()
                                        self.transferMainViewController.actionBack()
                                    case .signedTransaction:
                                        break
                                    }
                                case .failure(let error):
                                    self.alert(text: error.description)
                                    print(error.description)
                                }
                            }
                            
                        }
                    }
                    
                    break
                case .failed:
                    print("用户解锁失败")
                    break
                case .passwordNotSet , .touchidNotSet , .touchidNotAvailable , .canclePer , .inputNUm:
                    print("用户点击输入密码")
                    DispatchQueue.main.async {
                        let payAlert = PayAlert(frame: UIScreen.main.bounds)
                        payAlert.titleLabel.text = "请输入密码"
                        payAlert.show(view: self.controller.view)
                        payAlert.completeBlock = ({(password:String) -> Void in
                            print("输入的密码是:" + password)
                            if password == psd {
                                payAlert.removeFromSuperview()
                                self.controller.view.removeFromSuperview()
                            }else{
                                payAlert.clearPSD()
                                payAlert.titleLabel.text = "密码错误，请重新输入密码"
                            }
                        })
                    }
                    break
                default:
                    break
                }
            }
        }else{
            let transaction = configurator.signTransaction
            self.send(transaction: transaction) { [weak self] result in
                guard let `self` = self else { return }
                
                if (self.transferMainViewController.dappTransaction != nil){
                    self.transferMainViewController.didCompleted!(result)
                }else{
                    switch result {
                    case .success(let type):
                        switch type {
                        case .sentTransaction(let transaction):
                            mainTabBarController.addSentTransaction(transaction)
                            self.transferMainViewController.hideList()
                            self.transferMainViewController.actionBack()
                        case .signedTransaction:
                            break
                        }
                    case .failure(let error):
                        self.alert(text: LanguageHelper.getString(key: "交易失败"))
                        print(error)
                    }
                }
                
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
    
    func send(
        transaction: SignTransaction,
        completion: @escaping (Result<ConfirmResult, AnyError>) -> Void
        ) {
        if transaction.nonce >= 0 {
            signAndSend(transaction: transaction, completion: completion)
        } else {
            let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(
                address: session.account.address.description,
                state: "latest"
            )))
            Session.send(request) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let count):
                    let transaction = self.appendNonce(to: transaction, currentNonce: count)
                    self.signAndSend(transaction: transaction, completion: completion)
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    func signAndSend(
        transaction: SignTransaction,
        completion: @escaping (Result<ConfirmResult, AnyError>) -> Void
        ) {
        let signedTransaction = keystore.signTransaction(transaction)
        
        switch signedTransaction {
        case .success(let data):
            approve(confirmType: confirmType, transaction: transaction, data: data, completion: completion)
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
    
    func approve(confirmType: ConfirmType, transaction: SignTransaction, data: Data, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        let id = data.sha3(.keccak256).hexEncoded
        let sentTransaction = SentTransaction(
            id: id,
            original: transaction,
            data: data
        )
        let dataHex = data.hexEncoded
        switch confirmType {
        case .sign:
            completion(.success(.sentTransaction(sentTransaction)))
        case .signThenSend:
            let request = EtherServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: dataHex)))
            Session.send(request) { result in
                switch result {
                case .success:
                    completion(.success(.sentTransaction(sentTransaction)))
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
     func appendNonce(to: SignTransaction, currentNonce: BigInt) -> SignTransaction {
        return SignTransaction(
            value: to.value,
            account: to.account,
            to: to.to,
            nonce: currentNonce,
            data: to.data,
            gasPrice: to.gasPrice,
            gasLimit: to.gasLimit,
            chainID: to.chainID,
            localizedObject: to.localizedObject
        )
    }
    
//    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
//        return 24
//    }
//
//    func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
//        return 0.00001
//    }
    
//    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int) ->UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor(hex: "fafafa")
//        let titleLabel = UILabel(frame: CGRect(x:0, y:0,width:self.view.bounds.size.width-15, height:24))
//        titleLabel.text = "2018 6月25"
//        titleLabel.textColor = UIColor(hex: "666666")
//        titleLabel.font = UIFont.systemFont(ofSize: 13)
//        titleLabel.textAlignment = .right
//        headerView.addSubview(titleLabel)
//        return headerView
//    }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        if indexPath.row == 5 {
             return 120
        }else{
            return 60
        }
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
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
