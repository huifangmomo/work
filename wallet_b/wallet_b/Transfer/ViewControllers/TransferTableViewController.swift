//
//  TransferTableViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/16.
//  Copyright © 2018年 xhf. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import JSONRPCKit
import APIKit
import BigInt
import QRCodeReaderViewController
import TrustCore
import TrustKeystore

class TransferTableViewController: UITableViewController, QRCodeReaderDelegate,UITextFieldDelegate {
    
    var showType = 0
    var isHigh = false
    var transferMainViewController:TransferMainViewController!
    @IBOutlet weak var tokenName: UILabel!
    @IBOutlet weak var tokenBalance: UILabel!
    @IBOutlet weak var sendValue: UITextField!
    @IBOutlet weak var remarkTitle: UILabel!
    @IBOutlet weak var remarkValue: UITextField!
    @IBOutlet weak var toAddressTitle: UILabel!
    @IBOutlet weak var toAddressValue: UITextField!
    @IBOutlet weak var fromAddressTitle: UILabel!
    @IBOutlet weak var fromAddressValue: UILabel!
    @IBOutlet weak var gasFeeTitle_1: UILabel!
    @IBOutlet weak var gasFeeTitle_2: UILabel!
    @IBOutlet weak var gasFeeLab_1: UILabel!
    @IBOutlet weak var gasFeeLab_2: UILabel!
    @IBOutlet weak var switchTitle_1: UILabel!
    @IBOutlet weak var switchTitle_2: UILabel!
    @IBOutlet weak var gasSlider: UISlider!
    @IBOutlet weak var gasPriceValue: UITextField!
    @IBOutlet weak var gasValue: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var dataValue: UITextField!
    
    var session: WalletSession!
    var account: Account!
    var transferType: TransferType!
    var storage: TokensDataStore!
    var viewModel: SendViewModel!
    var config: Config!
    var currencyRate:CurrencyRate?
    var paymentFlow: PaymentFlow!
    
    var detailsViewModel: ConfirmPaymentDetailsViewModel!
    
    var configurator: TransactionConfigurator!
    
    private let fullFormatter = EtherNumberFormatter.full
    
    public var toAddressValueStr:String!
    public var sendValueStr:String!
    
    private var gasLimit: BigInt = BigInt(String(210000), radix: 10) ?? BigInt()
    private var gasPrice: BigInt {
        return fullFormatter.number(from: String(Int(gasSlider.value )), units: UnitConfiguration.gasPriceUnit) ?? BigInt()
    }
    private var totalFee: BigInt {
        return gasPrice * gasLimit
    }
    private var dataString: String {
        return self.dataValue.text ?? "0x"
    }
    
    private var gasViewModel: GasViewModel {
        return GasViewModel(fee: totalFee, server: config.server, currencyRate: currencyRate, formatter: fullFormatter)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.showType = 0
        self.isHigh = false
        self.gasPriceValue.delegate = self as UITextFieldDelegate
        self.gasValue.delegate = self as UITextFieldDelegate
        tableView.keyboardDismissMode = .onDrag
        
        mainTabBarController.getSendViewData(for: self)
        switch (paymentFlow!, session.account.type) {
        case (.send(let type), .privateKey(let account)),
             (.send(let type), .hd(let account)):
            self.transferType = type
            self.account = account
        case (.request(let token), _):

            break
        case (.send, .address):
            // This case should be returning an error inCoordinator. Improve this logic into single piece.
            break
        }
        currencyRate = session.balanceCoordinator.currencyRate

        
        viewModel = SendViewModel(transferType: transferType, config: session.config, chainState: session.chainState, storage: storage, balance: session.balance)
        self.tokenName.text = viewModel.symbol
        self.fromAddressValue.text = session.account.address.description
    
        let gasPriceGwei = EtherNumberFormatter.full.string(from: viewModel.gasPrice!, units: UnitConfiguration.gasPriceUnit)
        let price = max(Float(gasPriceGwei)!,1)
        self.gasPriceValue.text = String(price)
        self.gasValue.text = gasLimit.description
        self.gasSlider.value = price
        self.gasFeeLab_1.text = estimatedFeeText
        self.gasFeeLab_2.text = estimatedFeeText
        
        if toAddressValueStr != nil {
            self.toAddressValue.text = toAddressValueStr
        }
        if sendValueStr != nil {
            self.sendValue.text = sendValueStr
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = LanguageHelper.getString(key: "转账")
        self.tokenBalance.text = LanguageHelper.getString(key: "余额：") + viewModel.getBalance() + viewModel.symbol
        self.sendValue.placeholder = LanguageHelper.getString(key: "输入金额")
        self.remarkTitle.text = LanguageHelper.getString(key: "备注")
        self.remarkValue.placeholder = LanguageHelper.getString(key: "(选填)")
        self.toAddressTitle.text = LanguageHelper.getString(key: "收款地址")
        self.toAddressValue.placeholder = LanguageHelper.getString(key: "输入以太坊地址")
        self.fromAddressTitle.text = LanguageHelper.getString(key: "付款地址")
        self.nextBtn.setTitle(LanguageHelper.getString(key: "下一步"), for: .normal)
        self.gasFeeTitle_1.text = LanguageHelper.getString(key: "矿工费用")
        self.gasFeeTitle_2.text = LanguageHelper.getString(key: "矿工费用")
        self.switchTitle_1.text = LanguageHelper.getString(key: "高级模式")
        self.switchTitle_2.text = LanguageHelper.getString(key: "高级模式")
        self.gasPriceValue.placeholder = LanguageHelper.getString(key: "自定义") + " Gas Price"
        self.gasValue.placeholder = LanguageHelper.getString(key: "自定义") + " Gas"
        self.dataValue.placeholder = LanguageHelper.getString(key: "十六进制数据")
        
        //获取limit
        mainTabBarController.estimateGasLimit(for: self) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let gasLimit):
                print(gasLimit)
                self.gasValue.text = gasLimit.description
                self.gasLimit = gasLimit
                self.gasFeeLab_1.text = self.estimatedFeeText
                self.gasFeeLab_2.text = self.estimatedFeeText
            case .failure: break
            }
        }
        
        if (transferMainViewController.dappTransaction != nil) {
            self.dataValue.text = transferMainViewController.dappTransaction?.data?.hexEncoded
            self.toAddressValue.text = transferMainViewController.dappTransaction!.to?.description
            self.sendValue.text = "\(Double(transferMainViewController.dappTransaction!.value.description)!/1000000000000000000.0)"
        
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        NSLog("textFieldShouldEndEditing")
        if textField == self.gasValue {
            if BigInt(self.gasValue.text!, radix: 10) != nil {
                self.gasLimit = BigInt(String(210000), radix: 10) ?? BigInt()
                self.gasFeeLab_1.text = self.estimatedFeeText
                self.gasFeeLab_2.text = self.estimatedFeeText
            }else{
                alert(text: "gasLimit "+LanguageHelper.getString(key: "只能输入数字"))
            }
        }
        if textField == self.gasPriceValue {
            if Float(self.gasPriceValue.text!) != nil {
                self.gasSlider.value = Float(self.gasPriceValue.text!)!
                self.gasFeeLab_1.text = self.estimatedFeeText
                self.gasFeeLab_2.text = self.estimatedFeeText
            }else{
                alert(text: "gasPrice "+LanguageHelper.getString(key: "只能输入数字"))
            }
        }
        return true
    }
    
    var estimatedFeeText: String {
        let feeAndSymbol = gasViewModel.feeText
        return  feeAndSymbol
    }
    
    func send() {
        let addressString = self.toAddressValue.text
        let amountString = self.sendValue.text
        if self.sendValue.text == "" {
            alert(text: LanguageHelper.getString(key: "请输入转账金额"))
            return
        }
        guard let address = Address(string: addressString!) else {
            alert(text: LanguageHelper.getString(key: "请输入正确的地址"))
            return
        }
        let parsedValue: BigInt? = {
            switch transferType! {
            case .ether, .dapp, .nft:
                return EtherNumberFormatter.full.number(from: amountString!, units: .ether)
            case .token(let token):
                return EtherNumberFormatter.full.number(from: amountString!, decimals: token.decimals)
            }
        }()
        guard let value = parsedValue else {
            alert(text: LanguageHelper.getString(key: "转账的数额输入错误"))
            return
        }
        let transaction = UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: address,
            data: Data(hex: dataString.drop0x),
            gasLimit: gasLimit,
            gasPrice: gasPrice,
            nonce: .none
        )
        
        configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction
        )
        transferMainViewController.prices = self.sendValue.text
        transferMainViewController.transferConfirmViewController.configurator = configurator
        transferMainViewController.transferConfirmViewController.confirmType = .signThenSend
        transferMainViewController.transferConfirmViewController.session = session
        transferMainViewController.transferConfirmViewController.upDateView()
        
        transferMainViewController.showList()
    }

    
    @IBAction func back(_ sender: UIBarButtonItem) {
        transferMainViewController.actionBack()
    }

    @IBAction func scanningCallback(_ sender: UIButton) {
        openReader()
    }
    
    @objc func openReader() {
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
        
//        reader.dismiss(animated: true) { [weak self] in
////            self?.activateAmountView()
//            print("reader.dismiss")
//        }
        reader.dismiss(animated: true, completion: nil)
        
        guard let result = QRURLParser.from(string: result) else {
            alert(text: LanguageHelper.getString(key: "不是钱包"))
            return
        }
        self.toAddressValue.text = result.address
        if (result.params["amount"] != nil) {
            self.sendValue.text = result.params["amount"]
        }else{
            self.sendValue.text = ""
        }
        
//        addressRow?.value = result.address
//        addressRow?.reload()
        
//        if let dataString = result.params["data"] {
//            data = Data(hex: dataString.drop0x)
//        } else {
//            data = Data()
//        }
//
//        if let value = result.params["amount"] {
//            amountRow?.value = EtherNumberFormatter.full.string(from: BigInt(value) ?? BigInt(), units: .ether)
//        } else {
//            amountRow?.value = ""
//        }
//        amountRow?.reload()
//        viewModel.pairRate = 0.0
//        updatePriceSection()
    }
    
    @IBAction func addressBookCallback(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "AddressBookView") as! UINavigationController
        let vcFirst = vc.viewControllers.first as! AddressBookViewController
        vcFirst.presentViewController = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        self.gasFeeLab_1.text = estimatedFeeText
        self.gasFeeLab_2.text = estimatedFeeText
        let gasPriceGwei = EtherNumberFormatter.full.string(from: gasPrice, units: UnitConfiguration.gasPriceUnit)
        let price = max(Float(gasPriceGwei)!,1)
        self.gasPriceValue.text = String(price)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
        return 10
    }
    
    override func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        if section == 2 {
            if self.showType == 0{
                return 1
            }else if self.showType == 1{
                return 3
            }else{
                return 6
            }
            
        }else{
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            //只有第二个分区是动态的，其它默认
            if indexPath.section == 2 {
                let cell = super.tableView(tableView, cellForRowAt: indexPath)
                cell.isHidden = false
                if self.showType == 0{
      
                }else if self.showType == 1{
                    if indexPath.row == 0{
                        cell.isHidden = true
                    }
                }else{
                    if indexPath.row == 0 || indexPath.row == 2 {
                        cell.isHidden = true
                    }
                }
                return cell
            }else{
                return super.tableView(tableView, cellForRowAt: indexPath)
            }
    }
    
    override func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2{
            var hight = super.tableView(tableView, heightForRowAt: indexPath)
            if self.showType == 0{
                
            }else if self.showType == 1{
                if indexPath.row == 0{
                    hight = 0.00001
                }
            }else{
                if indexPath.row == 0 || indexPath.row == 2 {
                    hight = 0.00001
                }
            }
            
            return hight
        }else{
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        //print("点击"+String(indexPath.section)+String(indexPath.row))
        
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        if indexPath.section == 1 && indexPath.row == 0 {
            print("地址簿")
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            print("矿工费用1")
            if self.isHigh == false{
                self.showType = 1
            }else{
                self.showType = 2
            }
            self.tableView.reloadData()
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            print("矿工费用2")
            self.showType = 0
            self.tableView.reloadData()
        }
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        print(sender.tag)
        if sender.tag==0 && sender.isOn==true  {
            self.showType = 2
            self.isHigh = sender.isOn
            sender.isOn = !sender.isOn
        }else if sender.tag==1 && sender.isOn==false{
            self.showType = 1
            self.isHigh = sender.isOn
            sender.isOn = !sender.isOn
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func nextCallback(_ sender: UIButton) {
        send()
        self.sendValue.resignFirstResponder()
        self.remarkValue.resignFirstResponder()
        self.toAddressValue.resignFirstResponder()
        self.gasPriceValue.resignFirstResponder()
        self.gasValue.resignFirstResponder()
        self.dataValue.resignFirstResponder()
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
    //    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

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
