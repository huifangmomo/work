//
//  TransationsViewController.swift
//  wallet_b
//
//  Created by xhf on 2018/7/17.
//  Copyright © 2018年 xhf. All rights reserved.
//

import UIKit

class TransationsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
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
    
    var btnList = [UIButton]()
    var lineList = [UIImageView]()
    var dataSuorceArray = ["123","456","789"]
    
    var account:Wallet!
    var session:WalletSession!
    var viewModel:TransactionsViewModel!
    
    let refreshControl = UIRefreshControl()
    var timer: Timer?
    var updateTransactionsTimer: Timer?
    var showType: Int!
    var cellViewModel:TransactionDetailsViewModel!

    var imageNil:UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "交易"
        
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
        self.showType = 0
        viewModel = mainTabBarController.getTransactionsViewModel(for: self)
        viewModel.showType = 0
        
        
        tableView.register(UINib(nibName: "transactionCell", bundle: nil), forCellReuseIdentifier: "transactionCell")
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.backgroundColor = TransactionsViewModel.backgroundColor
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
//        topView.layer.addBorder(edge: UIRectEdge.bottom, color: UIColor.lightGray, thickness: 0.5)
        
        //runScheduledTimers()
        NotificationCenter.default.addObserver(self, selector: #selector(TransationsViewController.stopTimers), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TransationsViewController.restartTimers), name: .UIApplicationDidBecomeActive, object: nil)
        
        //transactionsObservation()
        //viewModel.updateSections()
//        let item=UIBarButtonItem(title: "分享", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        let item = UIBarButtonItem(title: "删除", style: UIBarButtonItemStyle.plain, target: self, action:#selector(deleteAll))
        
        self.imageNil = UIImageView(frame: CGRect(x: self.view.frame.size.width/2-70, y: self.view.frame.size.height/2-84, width: 140, height: 168))
        self.imageNil.image = UIImage(named: "alarm")
        self.view.addSubview(self.imageNil)
//        self.navigationItem.rightBarButtonItem=item
    }
    
    @objc func deleteAll() {
        refreshControl.beginRefreshing()
        viewModel.reGetAllTransaction()
        fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = LanguageHelper.getString(key: "交易")
        self.btn1.setTitle(LanguageHelper.getString(key: "全部"), for: .normal)
        self.btn2.setTitle(LanguageHelper.getString(key: "转出"), for: .normal)
        self.btn3.setTitle(LanguageHelper.getString(key: "转入"), for: .normal)
        self.btn4.setTitle(LanguageHelper.getString(key: "失败"), for: .normal)
        viewModel = mainTabBarController.getTransactionsViewModel(for: self)
        viewModel.showType = self.showType
        restartTimers()
        viewModel.updateSections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.endRefreshing()
        fetch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimers()
    }
    
    private func transactionsObservation() {
        viewModel.transactionsUpdateObservation { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.updateSections()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.tabBarItem.badgeValue = self.viewModel.badgeValue
        }
    }
    
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }
    
    func fetch() {
        viewModel.fetch { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc func stopTimers() {
        timer?.invalidate()
        timer = nil
        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
        viewModel.invalidateTransactionsObservation()
    }
    
    @objc func restartTimers() {
        runScheduledTimers()
        transactionsObservation()
    }
    
    private func runScheduledTimers() {
        guard timer == nil, updateTransactionsTimer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: BlockOperation { [weak self] in
            self?.viewModel.fetchPending()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
        updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 15, target: BlockOperation { [weak self] in
            self?.viewModel.fetchTransactions()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        //存在空值
        if viewModel != nil {
            viewModel.invalidateTransactionsObservation()
        }
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
        
        btnList[sender.tag].setTitleColor(UIColor(hex: "6694ff"),for: .normal) //普通状态下文字的颜色
        lineList[sender.tag].isHidden = false
        viewModel.showType = sender.tag
        self.showType = sender.tag
        viewModel.updateSections()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.numberOfSections == 0 {
            self.imageNil.isHidden = false
        }else{
            self.imageNil.isHidden = true
        }
        return viewModel.numberOfItems(for: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
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
        self.performSegue(withIdentifier: "TransactionsToDetails", sender: "跳转去详情")
    }
    
    //在这个方法中给新页面传递参数
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionsToDetails"{
            let controller = segue.destination as! DetailsTableViewController
            controller.viewModel = cellViewModel
            print(sender as? String as Any)
        }
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
