//
//  DetailsTableViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/17.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit
import BigInt
import Foundation
import APIKit
import JSONRPCKit
import Result
import TrustKeystore
import TrustCore

class DetailsTableViewController: UITableViewController {


    @IBOutlet weak var valueLab: UILabel!
    @IBOutlet weak var moneyLab: UILabel!
    @IBOutlet weak var recipinentLab: UILabel!
    @IBOutlet weak var transactionTitle: UILabel!
    @IBOutlet weak var transactionLab: UILabel!
    @IBOutlet weak var gasPriceTitle: UILabel!
    @IBOutlet weak var gasPriceLab: UILabel!
    @IBOutlet weak var confirmationTitle: UILabel!
    @IBOutlet weak var confirmationLab: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var nonceLab: UILabel!
    @IBOutlet weak var more: UIButton!
    @IBOutlet weak var reSend: UIButton!
    
    var viewModel: TransactionDetailsViewModel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        let view = UIView()
//        view.backgroundColor = UIColor.clear
//        tableView.tableFooterView = view
        timeLab.text = viewModel.createdAt
        valueLab.text = viewModel.amountString
        valueLab.textColor = viewModel.amountTextColor
        recipinentLab.text = viewModel.address
        transactionLab.text = viewModel.transactionID
        gasPriceLab.text = viewModel.gasFee
        confirmationLab.text = viewModel.confirmation
        nonceLab.text = viewModel.nonce
        moneyLab.text = viewModel.monetaryAmountString
        if viewModel.transaction.state == .pending {
            self.reSend.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = LanguageHelper.getString(key: "交易详情")
        self.transactionTitle.text = LanguageHelper.getString(key: "交易ID")
        self.gasPriceTitle.text = LanguageHelper.getString(key: "Gas价格")
        self.confirmationTitle.text = LanguageHelper.getString(key: "确认")
        self.timeTitle.text = LanguageHelper.getString(key: "交易时间")
        self.more.setTitle(LanguageHelper.getString(key: "更多详情"), for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func moreCallback(_ sender: UIButton) {
        self.performSegue(withIdentifier: "DetailsToWeb", sender: "跳转去浏览器")
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsToWeb"{
            let controller = segue.destination as! WebViewController
            controller.title = LanguageHelper.getString(key: "更多详情")
            guard let url = viewModel.detailsURL else { return }
            controller.URLString = url

            print(sender as? String as Any)
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
    }
    @IBAction func reSend(_ sender: UIButton) {
        //初始化UITextField
//        print(viewModel.transaction)
        let gasPrice:Double = Double(viewModel.transaction.gasPrice)!/1000000000
        print(gasPrice)
        var inputText:UITextField = UITextField();
        let msgAlertCtr = UIAlertController.init(title: "", message: "请输入燃油费", preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "确定", style:.default) { (action:UIAlertAction) ->() in
            let text:Double = Double(inputText.text!)!
            if(text >= gasPrice*1.1){
//                print("你输入的是：\(String(describing: inputText.text))")
                
                var n_account : Account!
                switch (self.viewModel.transactionViewModel.currentWallet.type) {
                case (.privateKey(let account)),
                     (.hd(let account)):
                    n_account = account

                case ( .address):
                    // This case should be returning an error inCoordinator. Improve this logic into single piece.
                    break
                }
                let data = UserDefaults.standard.data(forKey: self.viewModel.transaction.id)
                let chainID = UserDefaults.standard.integer(forKey: self.viewModel.transaction.id+"1")

                let transaction = SignTransaction(
                    value: BigInt(self.viewModel.transaction.value)!,
                    account: n_account,
                    to: self.viewModel.transaction.toAddress,
                    nonce: BigInt(self.viewModel.transaction.nonce),
                    data: data!,
                    gasPrice: BigInt(text*1000000000),
                    gasLimit: BigInt(self.viewModel.transaction.gas)!,
                    chainID: chainID,
                    localizedObject: self.viewModel.transaction.localizedOperations[0]
                )
                print(transaction)

                self.send(transaction: transaction) { [weak self] result in
                    guard let `self` = self else { return }
                    switch result {
                    case .success(let type):
                        switch type {
                        case .sentTransaction(let transaction):
                            UserDefaults.standard.removeObject(forKey: self.viewModel.transaction.id)
                            UserDefaults.standard.removeObject(forKey: self.viewModel.transaction.id+"1")
                            mainTabBarController.addSentTransaction(transaction)
                            self.navigationController?.popViewController(animated: true)
                        case .signedTransaction:
                            break
                        }
                    case .failure(let error):
                        self.alert(text: LanguageHelper.getString(key: "交易失败"))
                        print(error)
                    }
                    
//                    if (self.transferMainViewController.dappTransaction != nil){
//                        self.transferMainViewController.didCompleted!(result)
//                    }else{
//                        switch result {
//                        case .success(let type):
//                            switch type {
//                            case .sentTransaction(let transaction):
//                                mainTabBarController.addSentTransaction(transaction)
//                                self.transferMainViewController.hideList()
//                                self.transferMainViewController.actionBack()
//                            case .signedTransaction:
//                                break
//                            }
//                        case .failure(let error):
//                            self.alert(text: LanguageHelper.getString(key: "交易失败"))
//                            print(error)
//                        }
//                    }
                }
            }else{
                self.alert(text: LanguageHelper.getString(key: "燃油费过低"))
            }
        }
        
        let cancel = UIAlertAction.init(title: "取消", style:.cancel) { (action:UIAlertAction) -> ()in
            print("取消输入")
        }
        
        msgAlertCtr.addAction(ok)
        msgAlertCtr.addAction(cancel)
        //添加textField输入框
        msgAlertCtr.addTextField { (textField) in
            //设置传入的textField为初始化UITextField
            inputText = textField
//            inputText.placeholder = "输入数据"
            inputText.text =  String(format: "%f", gasPrice*1.2)
        }
        //设置到当前视图
        self.present(msgAlertCtr, animated: true, completion: nil)
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
                address: (viewModel.transaction.fromAddress?.description)!,
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
            approve(confirmType: .signThenSend, transaction: transaction, data: data, completion: completion)
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
