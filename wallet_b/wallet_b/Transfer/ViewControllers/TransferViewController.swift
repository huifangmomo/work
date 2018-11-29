//
//  TransferViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/10.
//  Copyright © 2018年 xhf. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class TransferViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var line1: UIImageView!
    @IBOutlet weak var line2: UIImageView!
    @IBOutlet weak var line3: UIImageView!
    @IBOutlet weak var line4: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var downView: UIView!
    @IBOutlet weak var getView: UIView!
    @IBOutlet weak var getTitle: UILabel!
    @IBOutlet weak var moneyIconImg: UIImageView!
    @IBOutlet weak var ewmImg: UIImageView!
    @IBOutlet weak var moneyTitle: UILabel!
    @IBOutlet weak var addressLab: UILabel!
    @IBOutlet weak var receiveBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var setMoneyBtn: UIButton!
    
    
    var btnList = [UIButton]()
    var lineList = [UIImageView]()
    var dataSuorceArray = ["123","456","789"]
    var tabBarVc:UITabBarController!
    var viewModel:TokenViewModel!
    var wallet:Wallet!
    var cellViewModel:TransactionDetailsViewModel!
    var paymentFlow: PaymentFlow!
    private let refreshControl = UIRefreshControl()
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var money: UILabel!
    var imageNil:UIImageView!
    var setMoney = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setMoney = 0
        btnList = [self.btn1, self.btn2, self.btn3, self.btn4]
        lineList = [self.line1, self.line2, self.line3, self.line4]
        
        for item in btnList {
            item.setTitleColor(UIColor(hex: "999999"),for: .normal) //普通状态下文字的颜色
            item.backgroundColor=UIColor.clear
            item.addTarget(self,action:#selector(tabBtnCallback),for:.touchUpInside)
        }
        for item in lineList {
            item.isHidden = true
        }
        
        btn1.setTitleColor(UIColor(hex: "6694ff"),for: .normal) //普通状态下文字的颜色
        line1.isHidden = false
        
        viewModel.showType = 0
        
        tableView.register(UINib(nibName: "transactionCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
//        topView.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.lightGray, thickness: 0.5)
//        downView.layer.addBorder(edge: UIRectEdge.top, color: UIColor.lightGray, thickness: 0.5)
        self.title = viewModel.title
        updateHeader()
        
        observToken()
        observTransactions()
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
    }
    
    @IBAction func requestCallback(_ sender: UIButton) {
        let request = URLRequest(url: viewModel.imageUrl!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
            }else{
                //将图片数据赋予UIImage
                let img = UIImage(data:data!)
                
                // 这里需要改UI，需要回到主线程
                DispatchQueue.main.async {
                    self.moneyIconImg.image = img
                }
                
            }
        }) as URLSessionTask
        
        //使用resume方法启动任务
        dataTask.resume()
        self.addressLab.text = viewModel.myAddressText
        self.getTitle.text = viewModel.title
        self.moneyTitle.text = LanguageHelper.getString(key: "请转入") + viewModel.symbol
        DispatchQueue.global(qos: .background).async {
            let image = QRGenerator.generate(from: self.viewModel.myAddressText)
            DispatchQueue.main.async {
                self.ewmImg.image = image
            }
        }
        self.getView.isHidden = false
        self.imageNil.isHidden = true
    }
    
    @IBAction func backCallback(_ sender: UIButton) {
        self.getView.isHidden = true
        if viewModel.numberOfSections == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
    }
    
    @IBAction func shareCallback(_ sender: UIButton) {
        print("分享")
        let items = [viewModel.myAddressText,self.ewmImg.image as Any]
        let activityViewController = UIActivityViewController.make(items: items)
        //activityViewController.popoverPresentationController?.barButtonItem = sender
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func copyCallback(_ sender: UIButton) {
        print("复制")
        UIPasteboard.general.string = viewModel.myAddressText
        alert(text: LanguageHelper.getString(key: "已经复制钱包地址到剪贴板"))
    }
    
    @IBAction func setMoneyCallback(_ sender: UIButton) {
        print("指定金额")
        showTextFieldAlert()
    }
    
    func showTextFieldAlert()  {
        var inputText:UITextField = UITextField();
        let msgAlertCtr = UIAlertController.init(title: LanguageHelper.getString(key: "提示"), message: LanguageHelper.getString(key: "请输入指定的金额"), preferredStyle: .alert)
        let ok = UIAlertAction.init(title: LanguageHelper.getString(key: "确认"), style:.default) { (action:UIAlertAction) ->() in
            print("你输入的是：\(String(describing: inputText.text))")
            if((inputText.text) == ""){
                
            }else{
                let str = inputText.text!
                if !self.onlyInputTheNumber(string: str){
                    self.alert(text: LanguageHelper.getString(key: "只能输入数字"))
                } else{
                    self.setMoney = Int(str)!
                    if self.setMoney==0 {
                        self.moneyTitle.text = LanguageHelper.getString(key: "请转入")+self.viewModel.symbol
                        let image = QRGenerator.generate(from: self.viewModel.myAddressText)
                        DispatchQueue.main.async {
                            self.ewmImg.image = image
                        }
                    }else{
                        self.moneyTitle.text = LanguageHelper.getString(key: "请转入")+String(self.setMoney) + " " + self.viewModel.symbol
                        let image = QRGenerator.generate(from: self.viewModel.myAddressText+","+String(self.setMoney))
                        DispatchQueue.main.async {
                            self.ewmImg.image = image
                        }
                    }

                }
            }
        }
        
        let cancel = UIAlertAction.init(title: LanguageHelper.getString(key: "取消"), style:.cancel) { (action:UIAlertAction) -> ()in
            print("取消输入")
        }
        
        msgAlertCtr.addAction(ok)
        msgAlertCtr.addAction(cancel)
        //添加textField输入框
        msgAlertCtr.addTextField { (textField) in
            //设置传入的textField为初始化UITextField
            inputText = textField
            inputText.placeholder = LanguageHelper.getString(key: "输入金额")
        }
        //设置到当前视图
        self.present(msgAlertCtr, animated: true, completion: nil)
    }
    
    func alert(text: String) {
        let alertController = UIAlertController(title: LanguageHelper.getString(key: "提示"),
                                                message: text, preferredStyle: .alert)
        let okAction = UIAlertAction(title: LanguageHelper.getString(key: "确认"), style: .default, handler: {
            action in
            if text==LanguageHelper.getString(key: "只能输入数字"){
                self.showTextFieldAlert()
            }
            
        })
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onlyInputTheNumber(string: String) -> Bool {
        let numString = "[0-9]*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", numString)
        let number = predicate.evaluate(with: string)
        return number
    }
    
    private func fetch() {
        viewModel.fetch()
    }
    
    private func observToken() {
        viewModel.tokenObservation { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.updateHeader()
            //self?.endLoading()
        }
    }
    
    private func observTransactions() {
        viewModel.transactionObservation { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
            //self?.endLoading()
        }
    }
    
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }
    
    private func updateHeader() {
        balance.text = viewModel.amount
        money.text = viewModel.totalFiatAmount
    }
    
    @IBAction func tabBtnCallback(_ sender: UIButton) {
        print(sender.tag)
        for item in btnList {
            item.setTitleColor(UIColor(hex: "999999"),for: .normal) //普通状态下文字的颜色
            item.backgroundColor=UIColor.clear
            item.addTarget(self,action:#selector(tabBtnCallback),for:.touchUpInside)
        }
        for item in lineList {
            item.isHidden = true
        }
        viewModel.showType = sender.tag
        viewModel.updateSections()
        btnList[sender.tag].setTitleColor(UIColor(hex: "6694ff"),for: .normal) //普通状态下文字的颜色
        lineList[sender.tag].isHidden = false
        fetch()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.numberOfSections == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.cellViewModel(for: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell")
        let tableCell =  cell as! transactionCell
        tableCell.img.image = model.statusImage
        tableCell.addressLab.text = model.subTitle
        tableCell.timeLab.text = model.createdTime
        tableCell.valueLab.text = model.amountString
        return cell!
    }
    
    func tableView(_ tableView:UITableView, heightForHeaderInSection section:Int) ->CGFloat{
        return 24
    }
    
    func tableView(_ tableView:UITableView, heightForFooterInSection section:Int) ->CGFloat{
        return 0.00001
    }

    func tableView(_ tableView:UITableView, viewForHeaderInSection section:Int) ->UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(hex: "fafafa")
        let titleLabel = UILabel(frame: CGRect(x:0, y:0,width:self.view.bounds.size.width-15, height:24))
        titleLabel.text = viewModel.titleForHeader(in: section)
        titleLabel.textColor = UIColor(hex: "666666")
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textAlignment = .right
        headerView.addSubview(titleLabel)
        return headerView
   }
    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath:IndexPath) ->CGFloat {
        return 44
    }
    
    func tableView(_ tableView:UITableView, didSelectRowAt indexPath:IndexPath){
        print("点击"+String(indexPath.row))
        tableView.deselectRow(at: indexPath, animated:true)//点击完成，取消高亮
        cellViewModel = viewModel.cellViewModel(for: indexPath)
        self.performSegue(withIdentifier: "TransferToDetails", sender: "跳转去详情")
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransferToDetails"{
            let controller = segue.destination as! DetailsTableViewController
            controller.viewModel = cellViewModel
            controller.title = cellViewModel.transactionID
            print(sender as? String as Any)
        }
        if segue.identifier == "TransferToTransferMain"{
            if wallet.type == .address(wallet.address) {
                let alertController = UIAlertController(title: LanguageHelper.getString(key: "提示"),
                                                        message: LanguageHelper.getString(key: "Watch用户暂未开通该功能"), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: LanguageHelper.getString(key: "确定"), style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                let controller = segue.destination as! TransferMainViewController
                controller.paymentFlow = paymentFlow
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) // No need for semicolon
        self.btn1.setTitle(LanguageHelper.getString(key: "全部"), for: .normal)
        self.btn2.setTitle(LanguageHelper.getString(key: "转出"), for: .normal)
        self.btn3.setTitle(LanguageHelper.getString(key: "转入"), for: .normal)
        self.btn4.setTitle(LanguageHelper.getString(key: "失败"), for: .normal)
        self.sendBtn.setTitle(LanguageHelper.getString(key: "转账"), for: .normal)
        self.receiveBtn.setTitle(LanguageHelper.getString(key: "收款"), for: .normal)
        self.setMoneyBtn.setTitle(LanguageHelper.getString(key: "指定金额"), for: .normal)
        self.tabBarVc?.tabBar.isHidden = true;
        fetch()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
